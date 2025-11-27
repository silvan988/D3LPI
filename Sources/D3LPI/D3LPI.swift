import Foundation

struct Contato: Codable {
    var email: String
    var telefone: String
    var idade: Int
}

actor AgendaManager {
    private var agenda: [String: Contato] = [:] 
    
    func mostrarDicionarioBruto() {
        if agenda.isEmpty {
            print("\n A agenda está vazia.")
        }   else {
            print("\n Número de contatos na agenda: \(agenda.count)")
            print(agenda)
        }   
        print("----------------------------------")
    }
    
    func getAgenda() -> [String: Contato] {
        return agenda
    }
    
    func getContato(nome: String) -> Contato? {
        return agenda[nome]
    }
    
    func setContato(nome: String, contato: Contato) async {
        agenda[nome] = contato
    }
    
    func removeContato(nome: String) -> Contato? {
        let removido = agenda.removeValue(forKey: nome)
        return removido
    }
}

let agendaManager = AgendaManager()

func criarContato(nome: String, email: String, telefone: String, idade: Int) async {
    let novoContato = Contato(email: email, telefone: telefone, idade: idade)
    
    if await agendaManager.getContato(nome: nome) != nil {
        print("\n Erro: Contato com o nome '\(nome)' já existe.")
        await agendaManager.mostrarDicionarioBruto() 
        return
    }
    
    await agendaManager.setContato(nome: nome, contato: novoContato)
    print("\n Contato '\(nome)' criado com sucesso!")
    await agendaManager.mostrarDicionarioBruto()
}

func atualizarContato(nome: String, novoEmail: String?, novoTelefone: String?, novaIdade: Int?) async {
    guard var contato = await agendaManager.getContato(nome: nome) else {
        print("\n Erro: Não foi possível atualizar. Contato com o nome '\(nome)' não encontrado.")
        return
    }
    
    if let email = novoEmail {
        contato.email = email
    }
    if let telefone = novoTelefone {
        contato.telefone = telefone
    }
    if let idade = novaIdade {
        contato.idade = idade
    }
    
    await agendaManager.setContato(nome: nome, contato: contato)
    print("\n Contato '\(nome)' atualizado com sucesso!")
    await agendaManager.mostrarDicionarioBruto() 
}

func deletarContato(nome: String) async {
    print("\n Tem certeza que deseja EXCLUIR o contato '\(nome)'? (s/N): ", terminator: "")
    guard let confirmacao = readLine()?.uppercased(), confirmacao == "S" else {
        print(" Exclusão cancelada.")
        await agendaManager.mostrarDicionarioBruto()
        return
    }

    if await agendaManager.removeContato(nome: nome) != nil {
        print("\n Contato '\(nome)' removido com sucesso!")
    } else {
        print("\n Erro: Não foi possível deletar. Contato com o nome '\(nome)' não encontrado.")
    }
    await agendaManager.mostrarDicionarioBruto()
}

func lerContato(nome: String) async {
    if let contato = await agendaManager.getContato(nome: nome) {
        print("\n Detalhes do Contato: \(nome)")
        print("   Nome:     \(nome)")
        print("   E-mail:   \(contato.email)")
        print("   Telefone: \(contato.telefone)")
        print("   Idade:    \(contato.idade) anos")
        print("----------------------------------")
    } else {
        print("\n Erro: Contato com o nome '\(nome)' não encontrado.")
    }
    await agendaManager.mostrarDicionarioBruto()
}

func lerTodosContatos() async {
    let agenda = await agendaManager.getAgenda()
    
    print("\n Lista de todos os contatos:")
    if agenda.isEmpty {
        print(" A agenda está vazia.")
        return
    }
    
    let separador = "=================================="
    
    for (nome, contato) in agenda.sorted(by: { $0.key < $1.key }) {
        print("\n\(separador)")
        print("Nome:     \(nome)")
        print("E-mail:   \(contato.email)")
        print("Telefone: \(contato.telefone)")
        print("Idade:    \(contato.idade) anos")
    }
    await agendaManager.mostrarDicionarioBruto()
}

func exibirMenu() {
    print("\n==================================")
    print("       Agenda de Contatos      ")
    print("==================================")
    print("1. Incluir dados de uma pessoa")
    print("2. Alterar dados de uma pessoa")
    print("3. Excluir dados de uma pessoa")
    print("4. Mostrar dados de uma pessoa")
    print("5. Mostrar dados de todas as pessoas")
    print("6. Finalizar o Programa")
    print("----------------------------------")
    print("Escolha uma opção (1-6): ", terminator: "")
}

func iniciarPrograma() async {
    var executando = true
    
    while executando {
        exibirMenu()
        
        guard let input = readLine(), let opcao = Int(input) else {
            print("\n Opção inválida. Por favor, digite um número de 1 a 6.")
            continue
        }
        
        switch opcao {
        case 1: 
            print("\n--- Incluir novo contato ---")
            
            var nome: String
            var nomeInvalido: Bool 
            
            repeat {
                print("Nome: ", terminator: "")
                nome = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if nome.isEmpty {
                    print(" O nome não pode ser vazio.")
                    nomeInvalido = true
                } else if await agendaManager.getContato(nome: nome) != nil { 
                    print(" Erro: Contato com o nome '\(nome)' já existe. Por favor, digite outro nome.")
                    nomeInvalido = true
                } else {
                    nomeInvalido = false
                }
            } while nomeInvalido             
            
            var email: String
            repeat {
                print("Email: ", terminator: "") 
                email = readLine() ?? ""
                let isValidEmailFormat = email.contains("@") && 
                                         email.first != "@" && 
                                         email.last != "@"
                //print(isValidEmailFormat)
                if email.isEmpty { 
                    print(" O email não pode ser vazio.") 
                } else if !isValidEmailFormat { 
                    print(" Formato de email inválido. Deve conter '@' e não pode estar no início ou no fim.") 
                }
            } while email.isEmpty || !email.contains("@") || email.first == "@" || email.last == "@"
            
            
            var telefone: String
            repeat {
                print("Telefone: ", terminator: "")
                telefone = readLine() ?? ""
                if telefone.isEmpty { print(" O telefone não pode ser vazio.") }
            } while telefone.isEmpty
            
            var idade: Int?
            repeat {
                print("Idade: ", terminator: "")
                if let idadeString = readLine(), let idadeConvertida = Int(idadeString), idadeConvertida > 0 {
                    idade = idadeConvertida
                } else {
                    print(" Idade inválida. Digite um número inteiro maior que zero.")
                }
            } while idade == nil
            
            await criarContato(nome: nome, email: email, telefone: telefone, idade: idade!)

        case 2: 
            print("\n--- Alterar contato ---")
            print("Nome do contato para alterar: ", terminator: "")
            guard let nome = readLine(), !nome.isEmpty else { 
                await agendaManager.mostrarDicionarioBruto()
                break 
            }
            
            guard let contatoAtual = await agendaManager.getContato(nome: nome) else {
                print("\n Contato '\(nome)' não encontrado.")
                await agendaManager.mostrarDicionarioBruto()
                break
            }
            
            print("\n-- Dados atuais --")
            print("Email Atual:    \(contatoAtual.email)")
            print("Telefone Atual: \(contatoAtual.telefone)")
            print("Idade Atual:    \(contatoAtual.idade)")
            print("\n----------------------------------")
            
            var novoEmail: String? = nil
            var emailValido = false
            
            repeat {
                print("Novo Email (deixe vazio para manter): ", terminator: "")
                let novoEmailInput = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                
                if novoEmailInput.isEmpty {
                    novoEmail = nil 
                    emailValido = true
                } else {
                    let isValidFormat = novoEmailInput.contains("@") && 
                                        novoEmailInput.first != "@" && 
                                        novoEmailInput.last != "@"
                    
                    if isValidFormat {
                        novoEmail = novoEmailInput
                        emailValido = true
                    } else {
                        print(" Formato de email inválido. Deve conter '@' e não pode estar no início ou no fim.")
                        emailValido = false
                    }
                }
            } while !emailValido
            
            print("Novo Telefone (deixe vazio para manter): ", terminator: "")
            let novoTelefoneInput = readLine()
            let novoTelefone = (novoTelefoneInput?.isEmpty == false) ? novoTelefoneInput : nil
            
            print("Nova Idade (deixe vazio para manter): ", terminator: "")
            let novaIdadeInput = readLine()
            let novaIdade: Int? = Int(novaIdadeInput ?? "")
            
            await atualizarContato(
                nome: nome, 
                novoEmail: novoEmail, 
                novoTelefone: novoTelefone, 
                novaIdade: novaIdade
            )
            
        case 3: 
            print("\n--- Excluir contato ---")
            print("Nome do contato para excluir: ", terminator: "")
            guard let nome = readLine(), !nome.isEmpty else { 
                await agendaManager.mostrarDicionarioBruto()
                break
            }

            guard (await agendaManager.getContato(nome: nome)) != nil else {
                print("\n Contato '\(nome)' não encontrado.")
                await agendaManager.mostrarDicionarioBruto() 
                break
            }
            
            await deletarContato(nome: nome)
            
        case 4: 
            print("\n--- Mostrar 1 contato ---")
            print("Nome do contato para mostrar: ", terminator: "")
            guard let nome = readLine(), !nome.isEmpty else { 
                await agendaManager.mostrarDicionarioBruto()
                break 
            }
            
            await lerContato(nome: nome)
            
        case 5: 
            await lerTodosContatos()
            
        case 6: 
            print("\n Programa encerrado. Obrigado!")
            executando = false
            
        default:
            print("\n Opção inválida. Por favor, digite um número de 1 a 6.")
        }
    }
}

@main
struct AvaliacaoApp {
    static func main() async {
        await iniciarPrograma()
    }
}
