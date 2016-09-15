//
//  ZazoCRUD.swift
//  Zazo
//
//  Created by Rinat on 21/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import ReactiveCocoa

protocol MessagesService: NSObjectProtocol {
    func get() -> SignalProducer<GetAllMessagesResponse, ServiceError>
    func getTranscript(by ID: String) -> SignalProducer<GetMessageResponse, ServiceError>
    func post(text: String, userID: String) -> SignalProducer<GenericResponse, ServiceError>
    func delete(by ID: String) -> SignalProducer<GenericResponse, ServiceError>
}

protocol AvatarService: NSObjectProtocol {
    func get() -> SignalProducer<GetAvatarResponse, ServiceError>
    func delete() -> SignalProducer<GenericResponse, ServiceError>
    func set(avatar: UIImage) -> SignalProducer<GenericResponse, ServiceError>
}
