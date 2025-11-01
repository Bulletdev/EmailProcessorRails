class ParceiroBParser
  include BaseParser

  private

  def extract_name(mail)
    # Captura nome até encontrar tag HTML ou final de linha
    extract_from_body(mail, /Customer Name:\s*([^<\n]+)/i) ||
      extract_from_body(mail, /Nome do Cliente:\s*([^<\n]+)/i)
  end

  def extract_email(mail)
    # Regex melhorado: captura apenas caracteres válidos de email
    extract_from_body(mail, /Contact Email:\s*([a-zA-Z0-9._+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/i) ||
      extract_from_body(mail, /Email de Contato:\s*([a-zA-Z0-9._+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/i)
  end

  def extract_phone(mail)
    extract_from_body(mail, /Phone:\s*([\d\s\-()]+)/i) ||
      extract_from_body(mail, /Telefone:\s*([\d\s\-()]+)/i)
  end

  def extract_product_code(mail)
    extract_from_body(mail, /Product Code:\s*([A-Z0-9-]+)/i) ||
      extract_from_body(mail, /Código do Produto:\s*([A-Z0-9-]+)/i) ||
      extract_from_body(mail, /Produto:\s*([A-Z0-9-]+)/i) ||
      # Busca no Subject por padrões como "PROD-999"
      extract_from_subject(mail, /[:-]\s*([A-Z]{2,}-?\d{3,})/i) ||
      # Fallback: qualquer padrão tipo PROD-999 ou ABC123
      extract_from_body(mail, /\b([A-Z]{2,}-?\d{3,})\b/)
  end

  def extract_from_subject(mail, pattern)
    return nil unless mail.subject

    match = mail.subject.match(pattern)
    match ? match[1].strip : nil
  end
end
