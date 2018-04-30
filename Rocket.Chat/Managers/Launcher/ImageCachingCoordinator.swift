//
//  ImageCachingCoordinator.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 30/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SDWebImage

struct ImageCachingCoordinator: LauncherProtocol {

    func prepareToLaunch(with options: [UIApplicationLaunchOptionsKey: Any]?) {
        // Set order of loading images to LIFO (last-in-first-out)
        SDWebImageManager.shared().imageDownloader?.executionOrder = .lifoExecutionOrder

        // 60 minutes
        SDImageCache.shared().config.maxCacheAge = 216000

        // 200MB disk cache size
        SDImageCache.shared().config.maxCacheSize = 209715200

        // ~100 avatars or ~10 big images
        // See more information about cost here: SDCacheCostForImage()
        SDImageCache.shared().maxMemoryCost = 5000000
    }

}
