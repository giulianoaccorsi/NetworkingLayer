import Foundation
import NetworkingLayer

// MARK: - Modelos de Exemplo

struct User: Codable, Sendable {
    let id: Int
    let name: String
    let email: String
}

struct CreateUserRequest: Codable, Sendable {
    let name: String
    let email: String
}

// MARK: - Endpoints de Exemplo

struct GetUsersEndpoint: SimpleGetEndpoint {
    let path = "/users"
}

struct GetUserEndpoint: SimpleGetEndpoint {
    let userId: Int
    var path: String { "/users/\(userId)" }
}

struct CreateUserEndpoint: PostEndpoint {
    typealias Body = CreateUserRequest
    
    let path = "/users"
    let requestBody: CreateUserRequest
    
    init(name: String, email: String) {
        self.requestBody = CreateUserRequest(name: name, email: email)
    }
}

struct UpdateUserEndpoint: PutEndpoint {
    typealias Body = CreateUserRequest
    
    let userId: Int
    let requestBody: CreateUserRequest
    
    var path: String { "/users/\(userId)" }
    
    init(userId: Int, name: String, email: String) {
        self.userId = userId
        self.requestBody = CreateUserRequest(name: name, email: email)
    }
}

struct DeleteUserEndpoint: DeleteEndpoint {
    let userId: Int
    var path: String { "/users/\(userId)" }
}

// MARK: - Service Layer de Exemplo

final class UserService {
    private let client: NetworkClientProtocol
    
    init(client: NetworkClientProtocol) {
        self.client = client
    }
    
    // MARK: - Usando Endpoints Estruturados
    
    func getUsers() async throws -> [User] {
        return try await client.request(
            endpoint: GetUsersEndpoint(),
            responseType: [User].self
        )
    }
    
    func getUser(id: Int) async throws -> User {
        return try await client.request(
            endpoint: GetUserEndpoint(userId: id),
            responseType: User.self
        )
    }
    
    func createUser(name: String, email: String) async throws -> User {
        return try await client.request(
            endpoint: CreateUserEndpoint(name: name, email: email),
            responseType: User.self
        )
    }
    
    func updateUser(id: Int, name: String, email: String) async throws -> User {
        return try await client.request(
            endpoint: UpdateUserEndpoint(userId: id, name: name, email: email),
            responseType: User.self
        )
    }
    
    func deleteUser(id: Int) async throws -> User {
        return try await client.request(
            endpoint: DeleteUserEndpoint(userId: id),
            responseType: User.self
        )
    }
    
    // MARK: - Usando Métodos de Conveniência
    
    func getUsersSimple() async throws -> [User] {
        return try await client.get(
            path: "/users",
            responseType: [User].self
        )
    }
    
    func createUserSimple(name: String, email: String) async throws -> User {
        let request = CreateUserRequest(name: name, email: email)
        return try await client.post(
            path: "/users",
            body: request,
            responseType: User.self
        )
    }
}

// MARK: - Exemplos de Uso

func exemploBasico() async {
    print("🚀 Exemplo Básico do NetworkModule")
    
    // Criar cliente simples
    let client = NetworkModule.createClient(baseURL: "https://jsonplaceholder.typicode.com")
    let userService = UserService(client: client)
    
    do {
        // Buscar usuários
        let users = try await userService.getUsers()
        print("✅ Busquei \(users.count) usuários")
        
        // Buscar usuário específico
        if let firstUser = users.first {
            let user = try await userService.getUser(id: firstUser.id)
            print("✅ Usuário: \(user.name) (\(user.email))")
        }
        
    } catch {
        print("❌ Erro: \(error.localizedDescription)")
    }
}

func exemploComAutenticacao() async {
    print("\n🔐 Exemplo com Autenticação")
    
    // Criar cliente com autenticação
    let client = NetworkModule.createAPIClient(
        baseURL: "https://api.exemplo.com",
        bearerToken: "seu-token-aqui"
    )
    
    let userService = UserService(client: client)
    
    do {
        // Criar novo usuário
        let newUser = try await userService.createUser(
            name: "João Silva",
            email: "joao@exemplo.com"
        )
        print("✅ Usuário criado: \(newUser.name)")
        
    } catch NetworkError.statusCode(let code, _) {
        print("❌ Erro HTTP: \(code)")
    } catch NetworkError.decodingError(let error) {
        print("❌ Erro de decodificação: \(error)")
    } catch {
        print("❌ Erro: \(error.localizedDescription)")
    }
}

func exemploComConfiguracaoPersonalizada() async {
    print("\n⚙️ Exemplo com Configuração Personalizada")
    
    // Configuração personalizada
    let configuration = NetworkConfiguration(
        baseURL: "https://api.exemplo.com",
        defaultHeaders: [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "MeuApp/1.0",
            "X-API-Version": "v2"
        ],
        timeoutInterval: 60.0,
        allowsCellularAccess: true
    )
    
    // Decoder personalizado
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601
    
    let client = NetworkModule.createClient(
        configuration: configuration,
        decoder: decoder,
        encoder: JSONEncoder()
    )
    
    let userService = UserService(client: client)
    
    do {
        let users = try await userService.getUsers()
        print("✅ Configuração personalizada funcionou! \(users.count) usuários")
    } catch {
        print("❌ Erro: \(error.localizedDescription)")
    }
}

func exemploComMock() async {
    print("\n🧪 Exemplo com Mock para Testes")
    
    #if DEBUG
    let mockClient = NetworkModule.createMockClient() as! MockNetworkClient
    
    // Configurar dados mock
    let mockUsers = [
        User(id: 1, name: "Mock User 1", email: "mock1@exemplo.com"),
        User(id: 2, name: "Mock User 2", email: "mock2@exemplo.com")
    ]
    
    do {
        try mockClient.setMockData(mockUsers)
        mockClient.requestDelay = 0.5 // Simular delay
        
        let userService = UserService(client: mockClient)
        let users = try await userService.getUsers()
        
        print("✅ Mock funcionou! \(users.count) usuários mock")
        for user in users {
            print("   - \(user.name): \(user.email)")
        }
        
    } catch {
        print("❌ Erro no mock: \(error.localizedDescription)")
    }
    #endif
}

// MARK: - Função Principal

func executarExemplos() async {
    await exemploBasico()
    await exemploComAutenticacao()
    await exemploComConfiguracaoPersonalizada()
    await exemploComMock()
    
    print("\n✅ Todos os exemplos executados!")
} 