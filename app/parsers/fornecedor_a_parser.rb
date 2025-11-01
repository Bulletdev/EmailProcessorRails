class FornecedorAParser
  include BaseParser

  private

  def extract_name(mail)
    # Captura nome até encontrar tag HTML ou final de linha
    extract_from_body(mail, /Nome:\s*([^<\n]+)/i) ||
      extract_from_body(mail, /Cliente:\s*([^<\n]+)/i)
  end

  def extract_email(mail)
    # Regex melhorado: captura apenas caracteres válidos de email (letras, números, pontos, hífens, underscores)
    # Para em: espaços, <, >, tags HTML, etc
    extract_from_body(mail, /E-?mail:\s*([a-zA-Z0-9._+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/i)
  end

  def extract_phone(mail)
    extract_from_body(mail, /Telefone:\s*([\d\s\-()]+)/i) ||
      extract_from_body(mail, /Tel:\s*([\d\s\-()]+)/i)
  end

  def extract_product_code(mail)
    # Tenta padrões estruturados primeiro
    extract_from_body(mail, /Produto:\s*([A-Z0-9-]+)/i) ||
      extract_from_body(mail, /Código:\s*([A-Z0-9-]+)/i) ||
      # Busca por "produto de código ABC123"
      extract_from_body(mail, /produto\s+de\s+código\s+([A-Z0-9-]+)/i) ||
      # Busca por "produto ABC123" (sem "de código")
      extract_from_body(mail, /produto\s+([A-Z][A-Z0-9-]{2,})/i) ||
      # Busca no Subject por padrões como "Produto ABC123"
      extract_from_subject(mail, /Produto\s+([A-Z][A-Z0-9-]{2,})/i) ||
      # Fallback: busca qualquer padrão que pareça código de produto (3+ letras maiúsculas seguidas de números)
      extract_from_body(mail, /\b([A-Z]{3,}-?\d{3,})\b/)
  end

  def extract_from_subject(mail, pattern)
    return nil unless mail.subject

    match = mail.subject.match(pattern)
    match ? match[1].strip : nil
  end
end
