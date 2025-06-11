import Foundation

// MARK: - Network Error
public enum NetworkError: Error, Sendable, LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case statusCode(Int, Data?)
    case decodingError(Error)
    case encodingError(Error)
    case networkError(Error)
    case timeout
    case cancelled
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .noData:
            return "Nenhum dado recebido"
        case .invalidResponse:
            return "Resposta inválida do servidor"
        case .statusCode(let code, _):
            return "Erro HTTP: \(code)"
        case .decodingError(let error):
            return "Erro ao decodificar dados: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Erro ao codificar dados: \(error.localizedDescription)"
        case .networkError(let error):
            return "Erro de rede: \(error.localizedDescription)"
        case .timeout:
            return "Timeout na requisição"
        case .cancelled:
            return "Requisição cancelada"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidURL:
            return "Verifique se a URL está correta"
        case .noData:
            return "Tente novamente mais tarde"
        case .invalidResponse:
            return "Verifique a conexão e tente novamente"
        case .statusCode(let code, _):
            return statusCodeSuggestion(for: code)
        case .decodingError:
            return "Verifique se o modelo de dados está correto"
        case .encodingError:
            return "Verifique os dados sendo enviados"
        case .networkError:
            return "Verifique sua conexão com a internet"
        case .timeout:
            return "Verifique sua conexão e tente novamente"
        case .cancelled:
            return "A operação foi cancelada"
        }
    }
    
    private func statusCodeSuggestion(for code: Int) -> String {
        switch code {
        case 400:
            return "Requisição inválida - verifique os parâmetros"
        case 401:
            return "Não autorizado - faça login novamente"
        case 403:
            return "Acesso negado - você não tem permissão"
        case 404:
            return "Recurso não encontrado"
        case 429:
            return "Muitas requisições - aguarde um momento"
        case 500...599:
            return "Erro do servidor - tente novamente mais tarde"
        default:
            return "Tente novamente mais tarde"
        }
    }
} 