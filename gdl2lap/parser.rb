#!/usr/bin/ruby

if ARGV.length != 1 
	puts "Uso: ./parser gdl_file"
	exit 
end


File.open("#{ARGV}") do |handle|

	# Pilha de relacoes
	rel_stack = []
	rs_sym = lambda {rel_stack.last[0]}
	rs_arg = lambda {rel_stack.last[1]}


	# Hash das relacoes
	rel_hash = Hash.new
	
	# Flag para empilhar a proxima relacao
	empilha = false

	
	handle.each_line do |linha|

		# Ignora comentarios e linhas vazias
		if linha[0].chr == ";" or linha == "\n"
			next
		end
		
		puts " ----------- ::#{linha.chomp} :: -------------"

		# Separa a string da linha para iteracao
		l_elems = linha.scan(/\w+|\(|\)|\<\=|\~\w+|\&|\^|\,|\?w+/)

		l_elems.each do |elem|
			print "elem :: \'#{elem}\'\n"
			puts "empilha :: #{empilha}"

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


			when /\w+/, /\~\w+/, "<="
				# Transforma o elemento em symbol
				elem = elem.to_sym

				# Caso nao exista, adiciona relacao na hash
				if not rel_hash.has_key?(elem) 
					rel_hash[elem] = []
				end

				# Se pilha nao vazia, aumenta o numero de args da relacao do topo
				if not rel_stack.empty?
					rel_stack.last[1] += 1				

					# Adiciona argumento na lista da relacao do topo
					if not rel_hash[rs_sym.call].nil?
						if rel_hash[rs_sym.call][rs_arg.call].nil?
							rel_hash[rs_sym.call][rs_arg.call] = []
						end
						if not rel_hash[rs_sym.call][rs_arg.call].include?(elem)
							rel_hash[rs_sym.call][rs_arg.call] << elem						
						end
					end
					
				end
				
				# Empilha
				if empilha
					rel_stack << [elem , 0]
				end
					empilha = false
				
			end
			elem = elem.to_s
			print "rel_stack :: ["
			rel_stack.each { |e| print "'#{e}' "}
			print "]\n"
			
			print "rels_hash ::\n"
			rel_hash.each do |e| 
				e.each do |l|
					if l.class == :teste.class
						print "   #{l} -> "
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
				
			print "</::>\n\n"

			
			
		end
	end
end


