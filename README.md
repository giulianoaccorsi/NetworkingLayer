# 🌐 NetworkModule

Um módulo moderno, abstrato e independente de rede para Swift com async/await (iOS 18+).

## ✨ Características

- 🚀 **Moderno**: Utiliza async/await e está otimizado para iOS 18+
- 🛡️ **Type-Safe**: Tipagem forte com protocolos e genéricos
- 🧱 **Modular**: Estrutura bem organizada e fácil de entender
- 🔌 **Plugável**: Interface baseada em protocolos, totalmente mockável
- 🎯 **Independente**: Sem dependências externas, apenas URLSession
- 🧪 **Testável**: Mock client incluído para testes

## 📁 Estrutura do Módulo

```
NetworkingLayer/
├── Core/
│   ├── NetworkClient.swift           // ✅ Implementação genérica
│   └── NetworkError.swift            // ✅ Erros tipados
├── Protocols/
│   ├── NetworkClientProtocol.swift   // ✅ Interface pública
│   └── EndpointProtocol.swift        // ✅ Como definir endpoints
├── Configuration/
│   └── NetworkConfiguration.swift    // ✅ Configuração injetável
├── Helpers/
│   └── HTTPMethod.swift              // ✅ Métodos HTTP
└── PublicAPI/
    └── NetworkModule.swift           // ✅ Ponto de entrada público
```

## 🚀 Instalação

Adicione ao seu `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/seu-usuario/NetworkModule.git", from: "1.0.0")
]
```

## 📖 Como Usar

### 1. Cliente Básico

```swift
import NetworkingLayer

// Criar cliente simples
let client = NetworkModule.createClient(baseURL: "https://api.exemplo.com")

// Usar métodos de conveniência
let users: [User] = try await client.get(
    path: "/users",
    responseType: [User].self
)
```

### 2. Endpoints Estruturados (Recomendado)

```swift
// Definir seus endpoints
struct GetUsersEndpoint: SimpleGetEndpoint {
    let path = "/users"
}

struct CreateUserEndpoint: PostEndpoint {
    typealias Body = CreateUserRequest
    
    let path = "/users"
    let requestBody: CreateUserRequest
    
    init(name: String, email: String) {
        self.requestBody = CreateUserRequest(name: name, email: email)
    }
}

// Usar nos seus services
final class UserService {
    private let client: NetworkClientProtocol
    
    init(client: NetworkClientProtocol) {
        self.client = client
    }
    
    func getUsers() async throws -> [User] {
        return try await client.request(
            endpoint: GetUsersEndpoint(),
            responseType: [User].self
        )
    }
    
    func createUser(name: String, email: String) async throws -> User {
        return try await client.request(
            endpoint: CreateUserEndpoint(name: name, email: email),
            responseType: User.self
        )
    }
}
```

### 3. Cliente com Autenticação

```swift
let client = NetworkModule.createAPIClient(
    baseURL: "https://api.exemplo.com",
    bearerToken: "seu-token-aqui"
)

// Ou com API Key
let client = NetworkModule.createAPIClient(
    baseURL: "https://api.exemplo.com",
    apiKey: "sua-api-key"
)
```

### 4. Configuração Personalizada

```swift
let configuration = NetworkConfiguration(
    baseURL: "https://api.exemplo.com",
    defaultHeaders: [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "User-Agent": "MeuApp/1.0"
    ],
    timeoutInterval: 60.0,
    allowsCellularAccess: true
)

let client = NetworkModule.createClient(configuration: configuration)
```

### 5. Decodificadores Personalizados

```swift
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
decoder.dateDecodingStrategy = .iso8601

let client = NetworkModule.createClient(
    configuration: configuration,
    decoder: decoder,
    encoder: JSONEncoder()
)
```

## 🧪 Testes com Mock

```swift
#if DEBUG
let mockClient = NetworkModule.createMockClient() as! MockNetworkClient

// Configurar dados mock
let mockUsers = [User(id: 1, name: "João", email: "joao@exemplo.com")]
try mockClient.setMockData(mockUsers)
mockClient.requestDelay = 0.5 // Simular delay

let userService = UserService(client: mockClient)
let users = try await userService.getUsers()
#endif
```

## 🎯 Protocolos de Conveniência

### Para GET simples:
```swift
struct GetUsersEndpoint: SimpleGetEndpoint {
    let path = "/users"
}
```

### Para POST com body:
```swift
struct CreateUserEndpoint: PostEndpoint {
    typealias Body = CreateUserRequest
    let path = "/users"
    let requestBody: CreateUserRequest
}
```

### Para PUT com body:
```swift
struct UpdateUserEndpoint: PutEndpoint {
    typealias Body = UpdateUserRequest
    let path = "/users/123"
    let requestBody: UpdateUserRequest
}
```

### Para DELETE:
```swift
struct DeleteUserEndpoint: DeleteEndpoint {
    let path = "/users/123"
}
```

## ❗ Tratamento de Erros

```swift
do {
    let users = try await userService.getUsers()
} catch NetworkError.statusCode(let code, _) {
    print("Erro HTTP: \(code)")
} catch NetworkError.decodingError(let error) {
    print("Erro de decodificação: \(error)")
} catch NetworkError.networkError(let error) {
    print("Erro de rede: \(error)")
} catch NetworkError.timeout {
    print("Timeout na requisição")
} catch {
    print("Erro: \(error.localizedDescription)")
}
```

## 🔧 Exemplo Completo de Integração

```swift
// Seus modelos
struct User: Codable, Sendable {
    let id: Int
    let name: String
    let email: String
}

// Seus endpoints
struct GetUsersEndpoint: SimpleGetEndpoint {
    let path = "/users"
}

// Seu service
final class UserService {
    private let client: NetworkClientProtocol
    
    init(client: NetworkClientProtocol) {
        self.client = client
    }
    
    func getUsers() async throws -> [User] {
        try await client.request(
            endpoint: GetUsersEndpoint(),
            responseType: [User].self
        )
    }
}

// Configuração no app
class AppContainer {
    lazy var networkClient: NetworkClientProtocol = {
        NetworkModule.createAPIClient(
            baseURL: "https://api.exemplo.com",
            bearerToken: AuthManager.shared.token
        )
    }()
    
    lazy var userService = UserService(client: networkClient)
}
```

## 🎛️ Factory Methods Disponíveis

```swift
// Cliente básico
NetworkModule.createClient(baseURL: "https://api.exemplo.com")

// Cliente com autenticação
NetworkModule.createAPIClient(baseURL: "https://api.exemplo.com", bearerToken: "token")

// Cliente para debug
NetworkModule.createDebugClient(baseURL: "https://api.exemplo.com")

// Cliente com configuração personalizada
NetworkModule.createClient(configuration: customConfig)

// Cliente mock para testes
NetworkModule.createMockClient() // Apenas em DEBUG
```

## 📋 Requisitos

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 5.9+
- Xcode 15.0+

## 🎯 Casos de Uso Ideais

- ✅ APIs REST modernas
- ✅ Projetos com múltiplos módulos/features
- ✅ Apps que precisam de flexibilidade na configuração de rede
- ✅ Projetos que valorizam testabilidade
- ✅ Integração com SwiftUI e UIKit

## 📄 Licença

MIT License. Veja o arquivo LICENSE para detalhes.
