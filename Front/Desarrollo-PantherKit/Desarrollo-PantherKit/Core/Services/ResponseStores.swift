import Foundation

// MARK: - Protocols (ISP)

protocol UserResponseStoring {
    func loadResponses() -> [UserResponse]
    func saveResponses(_ responses: [UserResponse])
    func clearResponses()
}

protocol APIResponseStoring {
    func loadAPIResponse() -> APIResponse?
    func saveAPIResponse(_ response: APIResponse)
    func clearAPIResponse()
}

// MARK: - Concrete Stores (UserDefaults-backed)

final class UserDefaultsUserResponseStore: UserResponseStoring {
    private let key = "UserTestResponses"

    func loadResponses() -> [UserResponse] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([UserResponse].self, from: data)
        } catch {
            AppLogger.make(category: "UserResponses").error("Decoding responses failed: \(error.localizedDescription)")
            return []
        }
    }

    func saveResponses(_ responses: [UserResponse]) {
        do {
            let data = try JSONEncoder().encode(responses)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            AppLogger.make(category: "UserResponses").error("Encoding responses failed: \(error.localizedDescription)")
        }
    }

    func clearResponses() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

final class UserDefaultsAPIResponseStore: APIResponseStoring {
    private let key = "LastAPIResponse"

    func loadAPIResponse() -> APIResponse? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(APIResponse.self, from: data)
        } catch {
            AppLogger.make(category: "APIResponse").error("Decoding APIResponse failed: \(error.localizedDescription)")
            return nil
        }
    }

    func saveAPIResponse(_ response: APIResponse) {
        do {
            let data = try JSONEncoder().encode(response)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            AppLogger.make(category: "APIResponse").error("Encoding APIResponse failed: \(error.localizedDescription)")
        }
    }

    func clearAPIResponse() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}


