# 🌐 NetworkingLayer

Módulo de Networking Reutilizável com API Fluente para iOS 18+ com suporte a async/await.

## ✨ Características

- 🚀 **Moderno**: Utiliza async/await otimizado para iOS 18+
- 🧱 **Builder Pattern**: Interface fluente e encadeável para criar requisições HTTP
- 🎯 **Type-Safe**: Tipagem forte com enums e protocolos
- 🔌 **Testável**: Interface baseada em protocolos, totalmente mockável  
- 🌍 **Localizado**: Mensagens de erro em PT-BR e EN
- 🛡️ **Independente**: Sem dependências externas, apenas URLSession


## 🚀 Instalação

### Swift Package Manager

Adicione ao seu `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/seu-usuario/NetworkingLayer.git", from: "1.0.0")
]
```

## 📖 Como Usar

### 1. Uso Básico com Builder Pattern

```swift
import NetworkingLayer

// Criar o client
let client = NetworkModule.defaultClient

// Criar requisição usando Builder Pattern (Exemplo do prompt)
let request = URLRequestBuilder()
    .path("https://www.teste.com.br/pokemon")
    .method(.get)
    .headers([.json, .custom("teste", "meme")])
    .body(.custom(["login": "giulianoaccorsi@gmail.com"]))
    .authentication(.bearer("token123"))

// Executar a requisição
struct PokemonResult: Codable {
    let name: String
    let url: String
}

struct PokemonList: Codable {
    let results: [PokemonResult]
}

let result = try await client.request(
    endpoint: request,
    responseType: PokemonList.self
)

print("Pokémons encontrados: \(result.results.count)")
```

### 2. Métodos de Conveniência

```swift
// GET simples
let getRequest = URLRequestBuilder.get("https://jsonplaceholder.typicode.com/posts/1")
    .headers([.json])
    .authentication(.bearer("token"))

// POST com dados
let postRequest = URLRequestBuilder.post("https://jsonplaceholder.typicode.com/posts")
    .headers([.json])
    .body(.custom([
        "title": "Meu Post",
        "body": "Conteúdo do post",
        "userId": 1
    ]))

// PUT para atualização
let putRequest = URLRequestBuilder.put("https://jsonplaceholder.typicode.com/posts/1")
    .headers([.json])
    .body(.json(myModel))

// DELETE
let deleteRequest = URLRequestBuilder.delete("https://jsonplaceholder.typicode.com/posts/1")
    .authentication(.bearer("token"))
```

### 3. Diferentes Tipos de Corpo (HTTPBody)

```swift
// Sem corpo
.body(.none)

// Dados brutos
.body(.raw(jsonData))

// Modelo Codable
.body(.json(user))

// Dicionário customizado
.body(.custom(["key": "value"]))

// String simples
.body(.string("Hello World"))
```

### 4. Headers e Autenticação

```swift
let request = URLRequestBuilder()
    .path("https://api.exemplo.com/data")
    .method(.post)
    // Headers predefinidos
    .headers([
        .json,              // Content-Type: application/json
        .xml,               // Content-Type: application/xml
        .formURLEncoded     // Content-Type: application/x-www-form-urlencoded
    ])
    // Headers customizados
    .header(.custom("X-API-Key", "12345"))
    .header(.custom("User-Agent", "MeuApp/1.0"))
    // Autenticação
    .authentication(.bearer("token123"))
    // Ou autenticação básica
    .authentication(.basic(username: "user", password: "pass"))
    // Ou API Key customizada
    .authentication(.apiKey("X-API-Key", "secret"))
```

### 5. Configurações Avançadas

```swift
let request = URLRequestBuilder()
    .path("https://api.exemplo.com/upload")
    .method(.post)
    .timeout(120.0)  // 2 minutos
    .cachePolicy(.reloadIgnoringLocalCacheData)
    .body(.raw(imageData))
```

### 6. Diferentes Formas de Resposta

```swift
// Com decodificação automática
let users: [User] = try await client.request(
    endpoint: request,
    responseType: [User].self
)

// Apenas dados brutos
let data: Data = try await client.request(endpoint: request)

// Sem retorno (para POST/PUT/DELETE)
try await client.request(endpoint: request)
```


### Tratamento Prático

```swift
do {
    let users = try await client.request(
        endpoint: request,
        responseType: [User].self
    )
    // Sucesso!
} catch NetworkError.unauthorized {
    // Usuário não autorizado - redirecionar para login
    showLoginScreen()
} catch NetworkError.noInternetConnection {
    // Sem internet - mostrar mensagem amigável
    showNoInternetAlert()
} catch NetworkError.decodingFailed {
    // Erro ao processar dados do servidor
    showDataErrorAlert()
} catch let error as NetworkError {
    // Outros erros de rede
    showErrorAlert(message: error.localizedDescription)
} catch {
    // Erros gerais
    showErrorAlert(message: error.localizedDescription)
}
```

## 🔧 Exemplo Completo - Service Layer

```swift
import NetworkingLayer

// MARK: - Models
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

struct CreateUserRequest: Codable {
    let name: String
    let email: String
}

// MARK: - User Service
final class UserService {
    private let client: NetworkClientProtocol
    
    init(client: NetworkClientProtocol = NetworkModule.defaultClient) {
        self.client = client
    }
    
    func getUsers() async throws -> [User] {
        let request = URLRequestBuilder.get("https://jsonplaceholder.typicode.com/users")
            .headers([.json])
        
        return try await client.request(
            endpoint: request,
            responseType: [User].self
        )
    }
    
    func createUser(name: String, email: String) async throws -> User {
        let request = URLRequestBuilder.post("https://jsonplaceholder.typicode.com/users")
            .headers([.json])
            .body(.custom([
                "name": name,
                "email": email
            ]))
        
        return try await client.request(
            endpoint: request,
            responseType: User.self
        )
    }
    
    func updateUser(id: Int, name: String, email: String) async throws -> User {
        let request = URLRequestBuilder.put("https://jsonplaceholder.typicode.com/users/\(id)")
            .headers([.json])
            .body(.json(CreateUserRequest(name: name, email: email)))
        
        return try await client.request(
            endpoint: request,
            responseType: User.self
        )
    }
    
    func deleteUser(id: Int) async throws {
        let request = URLRequestBuilder.delete("https://jsonplaceholder.typicode.com/users/\(id)")
        
        try await client.request(endpoint: request)
    }
}

// MARK: - Usage in SwiftUI
@Observable
class UserViewModel {
    var users: [User] = []
    var isLoading = false
    var errorMessage: String?
    
    private let userService = UserService()
    
    func loadUsers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            users = try await userService.getUsers()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
```

## 🎯 Funções Globais de Conveniência

```swift
// Em vez de URLRequestBuilder.get()
let request = get("https://api.example.com/users")
    .headers([.json])

// Em vez de URLRequestBuilder.post()
let request = post("https://api.example.com/users")
    .body(.json(user))

// Outros métodos disponíveis
put("https://api.example.com/users/1")
delete("https://api.example.com/users/1")
patch("https://api.example.com/users/1")
```
