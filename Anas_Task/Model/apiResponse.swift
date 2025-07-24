// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let aPIResponse = try? JSONDecoder().decode(APIResponse.self, from: jsonData)

import Foundation

// MARK: - APIResponse
struct APIResponse: Codable {
    let sections: [Section]
    let pagination: Pagination
}

// MARK: - Pagination
struct Pagination: Codable {
    let nextPage: String
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case nextPage = "next_page"
        case totalPages = "total_pages"
    }
}

// MARK: - Section
struct Section: Codable {
    let id = UUID()
    let name, content_type: String
    let type: String
    let order: Int
    let content: [Content]

    enum CodingKeys: String, CodingKey {
        case name, type , content_type
        case order, content
    }
}

// MARK: - Content
struct Content: Codable, Hashable {
    let name, description: String
    let avatarURL: String
    let episodeCount: Int?
    let duration: Int
    let language: Language?
    let priority, popularityScore: Int?
    let score: Double
    let podcastPopularityScore, podcastPriority: Int?
    let episodeID: String?
    let episodeType: EpisodeType?
    let podcastName: PodcastName?
    let authorName: AuthorName?
    let separatedAudioURL, audioURL: String?
    let releaseDate: String?
    let paidIsEarlyAccess, paidIsNowEarlyAccess, paidIsExclusive: Bool?
    let paidIsExclusivePartially: Bool?
    let paidExclusiveStartTime: Int?
    let audiobookID = UUID().uuidString
    let articleID = UUID().uuidString

    enum CodingKeys: String, CodingKey {
        case name, description
        case avatarURL = "avatar_url"
        case episodeCount = "episode_count"
        case duration, language, priority, popularityScore, score, podcastPopularityScore, podcastPriority
        case episodeID = "episode_id"
        case episodeType = "episode_type"
        case podcastName = "podcast_name"
        case authorName = "author_name"
        case separatedAudioURL = "separated_audio_url"
        case audioURL = "audio_url"
        case releaseDate = "release_date"
        case paidIsEarlyAccess = "paid_is_early_access"
        case paidIsNowEarlyAccess = "paid_is_now_early_access"
        case paidIsExclusive = "paid_is_exclusive"
        case paidIsExclusivePartially = "paid_is_exclusive_partially"
        case paidExclusiveStartTime = "paid_exclusive_start_time"
        case audiobookID = "audiobook_id"
        case articleID = "article_id"
    }
}

extension Content: DisplayableContent {
    var displayName: String { name }
    var displayScore:String { "\(score)" }
    var displayEpisodeType:String { "\(String(describing: episodeType))"}
    var displayDescription: String { description }
    var displayImageURL: String { avatarURL }
    var uniqueID: String { articleID }
}

enum AudiobookID: String, Codable {
    case audiobook001 = "audiobook_001"
}

enum AuthorName: String, Codable {
    case empty = ""
    case sunTzu = "Sun Tzu"
    case techWorld = "Tech World"
}

enum EpisodeType: String, Codable {
    case full = "full"
    case trailer = "trailer"
}

enum Language: String, Codable {
    case en = "en"
}

enum PodcastName: String, Codable {
    case nprNewsNow = "NPR News Now"
    case theNPRPoliticsPodcast = "The NPR Politics Podcast"
}

