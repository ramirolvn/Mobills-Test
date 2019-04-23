import Foundation
import Firebase

enum NetworkingError: Error {
    case someError
}

extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "O E-mail já está em uso"
        case .userNotFound:
            return "A conta não foi encontrada, por favor tente novamente!"
        case .userDisabled:
            return "Sua conta foi desabilitada, por favor entre em contato com o suporte!"
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return "E-mail inválido"
        case .networkError:
            return "Erro na conexão, por favor tente novamente!"
        case .weakPassword:
            return "Senha inválida, favor escolha uma senha mais forte!"
        case .wrongPassword:
            return "Senha errada!"
        default:
            return "Erro inesperado."
        }
    }
}

extension FirestoreErrorCode{
    var errorMessage: String {
        switch self {
        case .invalidArgument:
            return "Erro ao gravar documento"
        case .alreadyExists:
            return "O documento já existe"
        case .cancelled:
            return "Operação cancelada"
        case .permissionDenied:
            return "Permissão negada"
        case .dataLoss:
            return "Erro ao gravar documento"
        default:
            return "Erro inesperado ao gravar, favor tentar novamente."
        }
    }
}

