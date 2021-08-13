//
//  SearchResponseMapperTests.swift
//  UnsplashImageSearchTests
//
//  Created by Yupin Hu on 8/13/21.
//

import XCTest
@testable import UnsplashImageSearch

/*
plan:
 mapper responsible translate from json to Photo

 1, create json file

 */

class SearchResponseMapperTests: XCTestCase {

    func testThroughErrorWhenJsonInvalid() {
        let data = "invalid".data(using: .utf8)
        let sut = SearchResponseMapper()
        XCTAssertThrowsError(try sut.map(data!))
    }

    func testReturnEmptyArrayWithEmptyJson() {
        let emptyResultArray: [Photo] = []
        let empty: [String:Any] = ["result": emptyResultArray]
        let data = try! JSONSerialization.data(withJSONObject: empty)

        let sut = SearchResponseMapper()
        XCTAssertEqual([], try sut.map(data))
    }
}

class SearchResponseMapper {

    struct Response: Decodable {
        // dto
        let result: [APIPhoto]
    }

    struct APIUrls: Decodable {
        let thumb: URL
        let full: URL
    }

    struct APIPhoto: Decodable {
        let id: String
        let urls: APIUrls
        let likes: Int
        let description: String

        var photo: Photo {
            .init(id: id, thumbnail: urls.thumb, url: urls.full, likes: likes, description: description)
        }
    }

    enum Error: Swift.Error {
        case invalidData
    }

    func map(_ data: Data) throws -> [Photo] {
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(Response.self, from: data)
            return response.result.map { $0.photo }
        } catch {
            throw Error.invalidData
        }
    }
}
