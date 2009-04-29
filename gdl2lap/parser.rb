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

	# Flag para empilhar a proxima relacao lida
	empilha = false
	


	handle.each_line do |linha|

		# Ignora comentarios e linhas vazias
		if linha[0].chr == ";" or linha == "\n"
			next
		end
		
		print "$"+linha

		# Separa a string da linha para iteracao
		l_elems = linha.scan(/\w+|\(|\)|\<\=|\~\w+|\&|\^|\,|\?w+/)

		l_elems.each do |elem|
			case elem

			# Ativa flag para empilhar a proxima relacao
			when "("
				empilha = true
		
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

			when /\w+/, /\~\w+/
				
				# Relacao encontrada. Empilha e zera o numero de argumentos
				if empilha
					empilha = false
					rel_stack << [elem.to_sym , 0]
				# Relacao sem argumentos. Incremente o numero de args da relacao pai
				else
					rel_stack.last[1] += 1
				end

				# Caso nao exista, adiciona relacao na hash
				if not relations_hash.has_key?(elem.to_sym) 
					relations_hash[elem.to_sym] = []
				end

				# Adiciona argumento na lista da relacao que esta no
				# topo da pilha
				if relations_hash[rel_stack.last[0]][rel_stack.last[1]] == nil
					relations_hash[rel_stack.last[0]][rel_stack.last[1]] = []
				end

				if not rel_stack.last[0] == elem.to_sym 						
					if not
					relations_hash[rel_stack.last[0]][rel_stack.last[1]].include?(elem.to_sym) 
						relations_hash[rel_stack.last[0]][rel_stack.last[1]] <<
							elem.to_sym 
					end
				end
					
				
			end

			print "= '"+elem+"' -> ["
			rel_stack.each { |e| print "'#{e}' "}
			print "]\n"
			
			print ">> "
			relations_hash.each do |e| 
				e.each do |l|
					if l.class == :teste.class
						print "#{l} -> "
					else
						l.each do |x|
							if not x == nil
								print "["
								x.each {|y| print "#{y} "}
								print "]"
							end
						end
					end
				end
				print "\n"
			end
				
			print "<<\n\n"

			
			
		end
	end
end


