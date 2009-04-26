#!/usr/bin/ruby

if ARGV.length != 1 
	puts "Uso: ./parser gdl_file"
	exit 
end


File.open("#{ARGV}") do |handle|
	
	# Pilha de relacoes
	rel_stack = []

	# Hash das relacoes
	relations_hash = []
	
	# Controle dos '(' ')'
	p_control = 0

	handle.each_line do |linha|
		# Pega a relation e guarda na hash
		relations_hash = linha.gsub(/\(.*\)/, '')
		
		# Apaga espacos em branco
		linha.delete " "

		# Adiciona os elementos da linha na pilha
		rel_stack += [linha.scan(/\w+|\(|\)|\<\=|\~\w+|\&|\^/)]

		rel.stack.each do |elem|
			case elem
				when "("
				p_control += 1
				when ")"
				p_control -= 1
				when 
				
			end
		end
	end
end


