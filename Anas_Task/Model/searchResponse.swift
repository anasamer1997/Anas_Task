//
//  searchResponse.swift
//  Anas_Task
//
//  Created by Anas Amer on 28/01/1447 AH.
//
import Foundation

// MARK: - SearchResponse
struct SearchResponse: Codable {
    let sections: [SearchSection]
}

//MARK: - Section
struct SearchSection: Codable {
    let name, type, contentType, order: String
    let content: [SearchContent]

    enum CodingKeys: String, CodingKey {
        case name, type
        case contentType = "content_type"
        case order, content
    }
}

//MARK: - Content
struct SearchContent: Codable {
    let podcastID, name, description: String
    let avatarURL: String
    let episodeCount, duration, language, priority: String
    let popularityScore, score: String

    enum CodingKeys: String, CodingKey {
        case podcastID = "podcast_id"
        case name, description
        case avatarURL = "avatar_url"
        case episodeCount = "episode_count"
        case duration, language, priority, popularityScore, score
    }
    
}

extension SearchContent: DisplayableContent {
    var displayScore: String {
        score
    }
    
    var displayEpisodeType: String {
        ""
    }
    
    var displayName: String { name }
    var displayDescription: String { description }
    var displayImageURL: String { avatarURL }
    var uniqueID: String { podcastID }
}
