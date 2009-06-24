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

	# Hash da knowledge base
	kbase_hash = Hash.new

	# Hash das implicacoes
	# Guarda coisas que comecam com "<="
	impl_hash = Hash.new

	# Hash de variaveis para uma implicacao
	# A hash eh inicializada a cada nova implicacao	
	vars_hash = Hash.new
	
	# Flag para empilhar a proxima relacao
	empilha = false

	# Flag de implicacao
	implicacao = false
	
	handle.each_line do |linha|

		# Ignora comentarios e linhas vazias
		if linha[0].chr == ";" or linha == "\n"
			next
		end
		
		puts " ----------- ::#{linha.chomp} :: -------------"

		# Separa a string da linha para iteracao
		l_elems = linha.scan(/\w+|\(|\)|\<\=|\~\w+|\&|\^|\,|\?\w+/)

		l_elems.each do |elem|
			print "elem :: \'#{elem}\'\n"

			case elem

			# Ativa flag para empilhar a proxima relacao
			when "("
				empilha = true
		
			# rel) ... retira a relacao da pilha
			when  ")" 
				
				# Desempilha sempre
				rel_stack.pop
			
				if rel_stack.empty?
					# Nao estamos mais em uma implicacao
					implicacao = false
					
					# Limpa a Hash de variaveis
					vars_hash.clear
				end
				
			# Variaveis (maiusculas ou comecando com '?')
			when /[A-Z]/, /\?/
				# pilha vazia, nada pra fazer
				if rel_stack.empty?
					next 
				end

				# Aumenta o numero de argumentos
				rel_stack.last[1] += 1

				# Adiciona a var na hash
				elem = elem.to_sym
				if not vars_hash.has_key?(elem) 
					vars_hash[elem] = []
				end
				
				# Procura valoracao pra variavel na base de conhecimento
				if not kbase_hash[rs_sym.call].nil? 
					# Valoracao mais atualizada que a base. Atualiza a base
					if not kbase_hash[rs_sym.call][rs_arg.call].nil?
#					if not vars_hash[elem].nil? and
#							(vars_hash[elem] <=>
#							 kbase_hash[rs_sym.call][rs_arg.call]) == 1
						kbase_hash[rs_sym.call][rs_arg.call] = vars_hash[elem]
					else
						vars_hash[elem] = [kbase_hash[rs_sym.call][rs_arg.call]]
					end
					
				# Caso seja does, pega os jogadores
				elsif kbase_hash[rs_sym.call] == :does and
						not	vars_hash[elem] == kbase_hash[:role]
					vars_hash[elem] = [kbase_hash[:role]]
				end
				

			when "<="
				# Entramos em uma implicacao
				implicacao = true
				
				# Nao empilha mais
				empilha = false

			when /\w+/, /\~\w+/
				# Transforma o elemento em symbol
				elem = elem.to_sym

				### 
				### PARSER - IMPLICACAO
				###
				if implicacao
					# Se a pilha estiver vazia (consequencia da implicacao) e
					# ela ainda nao estiver na hash, adiciona 
					# Ex: rel_stack [], elem = row
					if rel_stack.empty? and impl_hash[elem].nil?
						impl_hash[elem] = []
					end
					
					# Uma nova condicao para implicacao, empilha
					if empilha 
						# Xunxo. Empilha a implicacao (next, row, column) 2x
						# para que ela so seja desempilhada quando os
						# precedentes acabarem 
						if rel_stack.empty?
							rel_stack << [elem, 0]
						end
						
						rel_stack << [elem, 0]
						empilha = false

						# Adiciona na KB qualquer coisa que nao seja uma palavra
						# reservada 
						if not [:next,:does, :init, :role, :true, :legal,
								:goal, :not].include?(elem)
							if not kbase_hash.has_key?(elem)
								kbase_hash[elem] = []
							end
						end

					# Uma variavel de alguma condicao. Verifica se a valoracao
					# ja esta na base de conhecimento, adiciona caso falhe a busca
					else
						rel_stack.last[1] += 1
						
						if not kbase_hash[rs_sym.call].nil? and not
								kbase_hash[rs_sym.call][rs_arg.call].include?(elem)
							kbase_hash[rs_sym.call][rs_arg.call] << elem
						end
							
					end

				### 
				### PARSER - AUMENTA BASE DE CONHECIMENTO
				###
				else
					# Caso nao exista, adiciona fato na KB
					if not kbase_hash.has_key?(elem) and empilha
						kbase_hash[elem] = []
					end

					# Se pilha nao vazia, aumenta o numero de args da relacao do topo
					if not rel_stack.empty?
						rel_stack.last[1] += 1

						# Adiciona argumento na lista da relacao do topo
						if not kbase_hash[rs_sym.call].nil?
							if kbase_hash[rs_sym.call][rs_arg.call].nil?
								kbase_hash[rs_sym.call][rs_arg.call] = []
							end
							if not kbase_hash[rs_sym.call][rs_arg.call].include?(elem)
								kbase_hash[rs_sym.call][rs_arg.call] << elem
							end
						end
						
					end
					
					# Empilha
					if empilha
						rel_stack << [elem , 0]
					end
					empilha = false

				end
			end

			puts "empilha :: #{empilha}"
			puts "implicacao :: #{implicacao}"


			elem = elem.to_s
			print "rel_stack :: ["
			rel_stack.each { |e| print "'#{e}' "}
			print "]\n"

			print "kbase_hash ::\n"
			kbase_hash.each do |e| 
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
			
			print "vars_hash :: \n"
			vars_hash.each do |e|
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

