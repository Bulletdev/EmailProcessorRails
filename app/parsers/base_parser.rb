module BaseParser
  def parse(mail_content)
    mail = Mail.read_from_string(mail_content)

    data = {
      name: extract_name(mail),
      email: extract_email(mail),
      phone: extract_phone(mail),
      product_code: extract_product_code(mail),
      subject: mail.subject
    }

    validate_contact_info(data)
    data
  end

  private

  def extract_name(mail)
    raise NotImplementedError, 'Subclass must implement extract_name'
  end

  def extract_email(mail)
    raise NotImplementedError, 'Subclass must implement extract_email'
  end

  def extract_phone(mail)
    raise NotImplementedError, 'Subclass must implement extract_phone'
  end

  def extract_product_code(mail)
    raise NotImplementedError, 'Subclass must implement extract_product_code'
  end

  def validate_contact_info(data)
    return unless data[:email].blank? && data[:phone].blank?

    raise StandardError, 'No contact information found (email or phone required)'
  end

  def extract_from_body(mail, pattern)
    body = mail_body_text(mail)
    # Force UTF-8 encoding to avoid incompatible encoding errors
    body = body.force_encoding('UTF-8') unless body.encoding == Encoding::UTF_8
    match = body.match(pattern)
    match ? match[1].strip : nil
  end

  def mail_body_text(mail)
    if mail.multipart?
      mail.text_part&.decoded || mail.html_part&.decoded || ''
    else
      mail.body.decoded
    end
  end
end
