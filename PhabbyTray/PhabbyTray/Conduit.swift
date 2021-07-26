//
//  Conduit.swift
//  PhabbyTray
//
//  Created by Tony Xu on 4/9/21.
//

import Foundation
import Alamofire
import RxSwift

/// Represent a phabrictor user.
struct PhabUser {
    let phabId: String
}

public extension NSDate {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self as Date, relativeTo: Date())
    }
}

public extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

struct Differential {
    let id: Int64
    let url: String
    let title: String
    let dateCreated: NSDate
    let dateModified: NSDate
}

class ConduitUrl {
    static let base_url = "https://phabricator.dropboxer.net/api"
    
    class func whoami() -> String {
        return "\(self.base_url)/user.whoami"
    }
    
    class func diffSearch() -> String {
        return "\(self.base_url)/differential.revision.search"
    }
}

enum GetFriendsFailureReason: Int, Error {
    case unAuthorized = 401
    case notFound = 404
}

// api-d2hwntdrdwnyoe63zg3xowejwaqi
public class ConduitAPI {
    private var apiToken: String

    init(apiToken: String) {
        self.apiToken = apiToken
    }
    
    func getMyReviewDiffs(phabUser: PhabUser) -> Observable<[Differential]> {
        let parameters: Parameters = [
            "api.token": self.apiToken,
            "constraints": [
                "reviewerPHIDs": [phabUser.phabId],
                "statuses": ["needs-review"]
            ]
        ]
        
        return Observable.create { observer -> Disposable in
            AF.request(ConduitUrl.diffSearch(), method: .post, parameters: parameters, encoding: URLEncoding.default)
                    .validate()
                    .responseJSON { response in
                        switch response.result {
                        case .success:
                            guard let data = response.data else {
                                // if no error provided by alamofire return .notFound error instead.
                                // .notFound should never happen here?
                                observer.onError(response.error ?? GetFriendsFailureReason.notFound)
                                return
                            }
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                if let jsonDict = json,
                                   let result = jsonDict["result"] as? [String: Any],
                                   let diffs = result["data"] as? [[String: Any]] {
                                    var newDiffs: [Differential] = []
                                    for diff in diffs {
                                        if let id = diff["id"] as? Int64,
                                           let fields = diff["fields"] as? [String: Any],
                                           let title = fields["title"] as? String,
                                           let url = fields["uri"] as? String,
                                           let dateCreated = fields["dateCreated"] as? Double,
                                           let dateModified = fields["dateModified"] as? Double
                                           {
                                            newDiffs.append(Differential(id: id, url: url, title: title,
                                                                         dateCreated: NSDate(timeIntervalSince1970: dateCreated),
                                                                         dateModified: NSDate(timeIntervalSince1970: dateModified)))
                                        }
                                    }
                                    observer.onNext(newDiffs)
                                } else {
                                    observer.onError(GetFriendsFailureReason.notFound)
                                }
                            } catch {
                                observer.onError(error)
                            }
                        case .failure(let error):
                            if let statusCode = response.response?.statusCode,
                                let reason = GetFriendsFailureReason(rawValue: statusCode)
                            {
                                observer.onError(reason)
                            } else {
                                observer.onError(error)
                            }
                        }
                }
         
                return Disposables.create()
            }
    }
    
    func getMyOpenDiffs(phabUser: PhabUser) -> Observable<[Differential]> {
        let parameters: Parameters = [
            "api.token": self.apiToken,
            "constraints": [
                "authorPHIDs": [phabUser.phabId],
                "statuses": ["needs-review"]
            ]
        ]
        
        return Observable.create { observer -> Disposable in
            AF.request(ConduitUrl.diffSearch(), method: .post, parameters: parameters, encoding: URLEncoding.default)
                    .validate()
                    .responseJSON { response in
                        switch response.result {
                        case .success:
                            guard let data = response.data else {
                                // if no error provided by alamofire return .notFound error instead.
                                // .notFound should never happen here?
                                observer.onError(response.error ?? GetFriendsFailureReason.notFound)
                                return
                            }
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                if let jsonDict = json,
                                   let result = jsonDict["result"] as? [String: Any],
                                   let diffs = result["data"] as? [[String: Any]] {
                                    var newDiffs: [Differential] = []
                                    for diff in diffs {
                                        if let id = diff["id"] as? Int64,
                                           let fields = diff["fields"] as? [String: Any],
                                           let title = fields["title"] as? String,
                                           let url = fields["uri"] as? String,
                                           let dateCreated = fields["dateCreated"] as? Double,
                                           let dateModified = fields["dateModified"] as? Double
                                        {
                                            newDiffs.append(Differential(id: id, url: url, title: title,
                                                                         dateCreated: NSDate(timeIntervalSince1970: dateCreated),
                                                                         dateModified: NSDate(timeIntervalSince1970: dateModified)))
                                        }
                                    }
                                    observer.onNext(newDiffs)
                                } else {
                                    observer.onError(GetFriendsFailureReason.notFound)
                                }
                            } catch {
                                observer.onError(error)
                            }
                        case .failure(let error):
                            if let statusCode = response.response?.statusCode,
                                let reason = GetFriendsFailureReason(rawValue: statusCode)
                            {
                                observer.onError(reason)
                            } else {
                                observer.onError(error)
                            }
                        }
                }
         
                return Disposables.create()
            }
        
    }
    
    func getLoggedinUser() -> Observable<PhabUser> {
        let parameters: Parameters = [
            "api.token": self.apiToken
        ]
        
        return Observable.create { observer -> Disposable in
                AF.request(ConduitUrl.whoami(), method: .post, parameters: parameters, encoding: URLEncoding.default)
                    .validate()
                    .responseJSON { response in
                        switch response.result {
                        case .success:
                            guard let data = response.data else {
                                // if no error provided by alamofire return .notFound error instead.
                                // .notFound should never happen here?
                                observer.onError(response.error ?? GetFriendsFailureReason.notFound)
                                return
                            }
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                if let jsonDict = json,
                                   let result = jsonDict["result"] as? [String: Any],
                                   let phid = result["phid"] as? String {
                                    observer.onNext(PhabUser(phabId: phid))
                                } else {
                                    observer.onError(GetFriendsFailureReason.notFound)
                                }
                            } catch {
                                observer.onError(error)
                            }
                        case .failure(let error):
                            if let statusCode = response.response?.statusCode,
                                let reason = GetFriendsFailureReason(rawValue: statusCode)
                            {
                                observer.onError(reason)
                            } else {
                                observer.onError(error)
                            }
                        }
                }
         
                return Disposables.create()
            }
    }
    
}
