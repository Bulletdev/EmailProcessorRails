namespace :data do
  desc 'Limpa customers duplicados e email logs'
  task cleanup: :environment do
    puts '🧹 Limpando dados duplicados...'

    # Limpar customers duplicados (mantém apenas o primeiro de cada email)
    duplicates_count = 0
    Customer.select(:email).group(:email).having('COUNT(*) > 1').pluck(:email).each do |email|
      duplicates = Customer.where(email: email).order(:id).offset(1)
      duplicates_count += duplicates.count
      duplicates.destroy_all
    end
    puts "✅ Removidos #{duplicates_count} customers duplicados"

    # Limpar todos os email_logs
    logs_count = EmailLog.count
    EmailLog.destroy_all
    puts "✅ Removidos #{logs_count} email logs"

    # Limpar ActiveStorage órfãos
    attachments_count = ActiveStorage::Attachment.where(record_type: 'EmailLog').count
    ActiveStorage::Attachment.where(record_type: 'EmailLog').destroy_all
    puts "✅ Removidos #{attachments_count} attachments"

    puts "\n🎉 Limpeza concluída!"
  end

  desc 'Limpa TODOS os customers (cuidado!)'
  task cleanup_all_customers: :environment do
    print '⚠️  Isso vai DELETAR TODOS os customers. Tem certeza? (yes/no): '
    confirmation = $stdin.gets.chomp

    if confirmation == 'yes'
      count = Customer.count
      Customer.destroy_all
      puts "✅ Removidos #{count} customers"
    else
      puts '❌ Operação cancelada'
    end
  end
end
