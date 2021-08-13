//
//  SearchResponseMapperTests.swift
//  UnsplashImageSearchTests
//
//  Created by Yupin Hu on 8/13/21.
//

import XCTest
@testable import UnsplashImageSearch

class SearchResponseMapperTests: XCTestCase {

    typealias APIPhoto = SearchResponseMapper.APIPhoto

    func testThroughErrorWhenJsonInvalid() {
        let data = "invalid".data(using: .utf8)
        let sut = SearchResponseMapper()
        XCTAssertThrowsError(try sut.map(data!))
    }

    func testReturnEmptyArrayWithEmptyJson() {
        let emptyResultArray: [Photo] = []
        let empty: [String:Any] = ["results": emptyResultArray]
        let data = try! JSONSerialization.data(withJSONObject: empty)

        let sut = SearchResponseMapper()
        XCTAssertEqual([], try sut.map(data))
    }

    func testReturnPhotosArrayWithAPIJson() throws {
        let bundle = Bundle(for: Self.self)
        let filepath = bundle.path(forResource: "PhotoSearchResponse", ofType: "json")!
        let data = try! Data(contentsOf: URL.init(fileURLWithPath: filepath))

        let sut = SearchResponseMapper()
        let photos = try XCTUnwrap(try? sut.map(data))
        XCTAssertEqual(photos.count, 3)
    }

    func testReturnPhotosArrayWithStubbedJson() throws {
        let photo1 = makePhoto(id: "1", thumbnail: URL(string: "www.thumb.com/1")!, url: URL(string: "www.full.com/1")!, likes: 1, description: "Image1")
        let photo2 = makePhoto(id: "2", thumbnail: URL(string: "www.thumb.com/2")!, url: URL(string: "www.full.com/2")!, likes: 2, description: "Image2")


        let photosJsonArray: [[String:Any]] = [photo1.apiPhoto, photo2.apiPhoto]
        let photosJsonDictionary: [String: Any] = ["results": photosJsonArray]
        let data = try! JSONSerialization.data(withJSONObject: photosJsonDictionary)

        let sut = SearchResponseMapper()
        let photos = try XCTUnwrap(try? sut.map(data))
        XCTAssertEqual(photos.count, 2)

        let expectedPhotos: [Photo] = [photo1.expectedPhoto, photo2.expectedPhoto]
        XCTAssertEqual(photos, expectedPhotos)
    }

    // MARK: Helpers:
    func makePhoto(id: String, thumbnail: URL, url: URL, likes: Int, description: String) -> (apiPhoto: [String:Any], expectedPhoto: Photo) {
        let apiPhoto: [String:Any] = [
            "id": id,
            "urls": ["thumb": thumbnail.absoluteString, "full": url.absoluteString],
            "likes": likes,
            "description": description
        ]
        let expectedPhoto = Photo(id: id, thumbnail: thumbnail, url: url, likes: likes, description: description)
        return (apiPhoto, expectedPhoto)
    }
}

class SearchResponseMapper {

    struct Response: Decodable {
        let results: [APIPhoto]
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
        guard let response = try? JSONDecoder().decode(Response.self, from: data) else {
            throw Error.invalidData
        }
        return response.results.map { $0.photo }
    }
}
