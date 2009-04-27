#!/usr/bin/ruby

if ARGV.length != 1 
	puts "Uso: ./parser gdl_file"
	exit 
end


File.open("#{ARGV}") do |handle|

	# Pilha de relacoes
	rel_stack = []

	# Hash das relacoes
	relations_hash = Hash.new
	
	handle.each_line do |linha|

		# Separa a string da linha para iteracao
		l_elems = linha.scan(/\w+|\(|\)|\<\=|\~\w+|\&|\^|\,|\?w+/)

		print "["
		rel_stack.each { |e| print "'#{e}' "}
		print "]\n"


		l_elems.each do |elem|
			case elem

			# do nothing
			when "("
		
			# rel) ... retira a relacao da pilha
			when  ")" 
				rel_stack.pop
				
			# Variaveis (maiusculas ou comecando com '?')
			when /[A-Z]/, /\?/
				# pilha vazia, nada pra fazer
				if rel_stack.empty?
					next 
				end

				# Aumenta o numero de argumentos
				rel_stack.last[1] += 1

			# Valores (entradas instanciadas)
			when /\d/
				# pilha vazia, nada a fazer
				if rel_stack.empty? 
					next
				end

				# Inc numero de argumentos
				rel_stack.last[1] += 1

				# Extrai a relacao do topo e adiciona o valor na lista 
				# argumentos possiveis
				relation = rel_stack.last[0]
				arg_num = rel_stack.last[1]
				#relations_hash[relation][arg_num] << elem

			when /\w+/, /\~\w+/
				print "\n$#{elem}$"

				# Empilha relacao + numeros de argumentos
				rel_stack << [elem , 0]
				puts rel_stack
				
				# Caso nao exista, adiciona relacao na hash
				if relations_hash.has_key?(elem.to_sym) 
					relations_hash[elem.to_sym] = []
				end
			end
		end
	end
end


