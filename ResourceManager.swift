import Foundation

public struct ResourceManager {
    public enum ResourceManagerError: Error {
        case resourceNotFound
        case jsonFailedToGenerate
    }

    public static func resourcesNames(in directoryPath: String) -> [String] {
        let paths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: directoryPath)
        return paths.compactMap {
            $0.components(separatedBy: "/").last?.components(separatedBy: ".").first
        }.sorted()
    }

    public static func data(for resourceName: String, directoryPath: String, formatted: Bool = true) throws -> Data {
        guard let path = Bundle.main.path(forResource: resourceName, ofType: "json", inDirectory: directoryPath) else {
            throw ResourceManagerError.resourceNotFound
        }

        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

        guard formatted else { return data }

        let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        let formattedData = try JSONSerialization.data(withJSONObject: jsonResult, options: .prettyPrinted)
        return formattedData
    }

    public static func json(for resourceNames: [String], inDirectory directoryPath: String) throws -> [[AnyHashable: Any]] {
        try resourceNames.map {
            guard let resourcePath = Bundle.main.path(forResource: $0, ofType: "json", inDirectory: directoryPath) else {
                throw ResourceManagerError.resourceNotFound
            }

            let data = try Data(contentsOf: URL(fileURLWithPath: resourcePath), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            guard let jsonResult = jsonResult as? [[AnyHashable: Any]], let result = jsonResult.first else {
                throw ResourceManagerError.jsonFailedToGenerate
            }
            return result
        }
    }
}
