//
//  PhotoModel.swift
//  PhotoListDemo
//
//  Created by HS Lee on 2020/06/25.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation

// MARK: - Photo
struct Photo: Codable {
    let id: String
    let createdAt: Date?
    let updatedAt: Date?
    let promotedAt: Date?
    let width: Int?
    let height: Int?
    let color: String?
    let photoDescription: String?
    let altDescription: String?
    let urls: Urls?
    let likes: Int?
    let likedByUser: Bool?
    let user: User?
    let exif: Exif?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case promotedAt = "promoted_at"
        case width = "width"
        case height = "height"
        case color = "color"
        case photoDescription = "description"
        case altDescription = "alt_description"
        case urls = "urls"
        case likes = "likes"
        case likedByUser = "liked_by_user"
        case user = "user"
        case exif
    }
}

// MARK: - Exif
struct Exif: Codable {
    let make: String?
    let model: String?
    let exposureTime: String?
    let aperture: String?
    let focalLength: String?
    let iso: String?

    enum CodingKeys: String, CodingKey {
        case make = "make"
        case model = "model"
        case exposureTime = "exposure_time"
        case aperture = "aperture"
        case focalLength = "focal_length"
        case iso = "iso"
    }
}

// MARK: - Urls
struct Urls: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String

    enum CodingKeys: String, CodingKey {
        case raw = "raw"
        case full = "full"
        case regular = "regular"
        case small = "small"
        case thumb = "thumb"
    }
}

// MARK: - User
struct User: Codable {
    let id: String?
    let updatedAt: Date?
    let username: String?
    let name: String?
    let firstName: String?
    let lastName: String?
    let twitterUsername: String?
    let portfolioUrl: String?
    let bio: String?
    let location: String?
    let instagramUsername: String?
    let totalCollections: Int?
    let totalLikes: Int?
    let totalPhotos: Int?
    let acceptedTos: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case updatedAt = "updated_at"
        case username = "username"
        case name = "name"
        case firstName = "first_name"
        case lastName = "last_name"
        case twitterUsername = "twitter_username"
        case portfolioUrl = "portfolio_url"
        case bio = "bio"
        case location = "location"
        case instagramUsername = "instagram_username"
        case totalCollections = "total_collections"
        case totalLikes = "total_likes"
        case totalPhotos = "total_photos"
        case acceptedTos = "accepted_tos"
    }
}

