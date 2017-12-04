/*
 Copyright 2017 Avery Pierce
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation


/**
 Types of Matrix events
 
 Matrix events types are exchanged as strings with the home server. The types
 specified by the Matrix standard are listed here as NSUInteger enum in order
 to ease the type handling.
 
 Custom events types, out of the specification, may exist. In this case,
 `MXEventTypeString` must be checked.
 */
public enum MXEventType : Equatable, Hashable {
    case roomName
    case roomTopic
    case roomAvatar
    case roomMember
    case roomCreate
    case roomJoinRules
    case roomPowerLevels
    case roomAliases
    case roomCanonicalAlias
    case roomEncrypted
    case roomEncryption
    case roomGuestAccess
    case roomHistoryVisibility
    case roomKey
    case roomForwardedKey
    case roomKeyRequest
    case roomMessage
    case roomMessageFeedback
    case roomRedaction
    case roomThirdPartyInvite
    case roomTag
    case presence
    case typing
    case callInvite
    case callCandidates
    case callAnswer
    case callHangup
    case receipt
    case readMarker
    
    case custom(String)
    
    public var identifier: String {
        switch self {
        case .roomName: return kMXEventTypeStringRoomName
        case .roomTopic: return kMXEventTypeStringRoomTopic
        case .roomAvatar: return kMXEventTypeStringRoomAvatar
        case .roomMember: return kMXEventTypeStringRoomMember
        case .roomCreate: return kMXEventTypeStringRoomCreate
        case .roomJoinRules: return kMXEventTypeStringRoomJoinRules
        case .roomPowerLevels: return kMXEventTypeStringRoomPowerLevels
        case .roomAliases: return kMXEventTypeStringRoomAliases
        case .roomCanonicalAlias: return kMXEventTypeStringRoomCanonicalAlias
        case .roomEncrypted: return kMXEventTypeStringRoomEncrypted
        case .roomEncryption: return kMXEventTypeStringRoomEncryption
        case .roomGuestAccess: return kMXEventTypeStringRoomGuestAccess
        case .roomHistoryVisibility: return kMXEventTypeStringRoomHistoryVisibility
        case .roomKey: return kMXEventTypeStringRoomKey
        case .roomForwardedKey: return kMXEventTypeStringRoomForwardedKey
        case .roomKeyRequest: return kMXEventTypeStringRoomKeyRequest
        case .roomMessage: return kMXEventTypeStringRoomMessage
        case .roomMessageFeedback: return kMXEventTypeStringRoomMessageFeedback
        case .roomRedaction: return kMXEventTypeStringRoomRedaction
        case .roomThirdPartyInvite: return kMXEventTypeStringRoomThirdPartyInvite
        case .roomTag: return kMXEventTypeStringRoomTag
        case .presence: return kMXEventTypeStringPresence
        case .callInvite: return kMXEventTypeStringCallInvite
        case .callCandidates: return kMXEventTypeStringCallCandidates
        case .callAnswer: return kMXEventTypeStringCallAnswer
        case .callHangup: return kMXEventTypeStringCallHangup
        case .receipt: return kMXEventTypeStringReceipt
        case .readMarker: return kMXEventTypeStringReadMarker
            
        // Swift converts any constant with the suffix "Notification" as the type `Notification.Name`
        // The original value can be reached using the `rawValue` property.
        case .typing: return NSNotification.Name.mxEventTypeStringTyping.rawValue
            
        case .custom(let string): return string
        }
    }
    
    
    public var rawValue: __MXEventType {
        return MXTools.eventType(identifier)
    }
    
    static var allStaticValues: [MXEventType] {
        return [
            .roomName,
            .roomTopic,
            .roomAvatar,
            .roomMember,
            .roomCreate,
            .roomJoinRules,
            .roomPowerLevels,
            .roomAliases,
            .roomCanonicalAlias,
            .roomEncrypted,
            .roomEncryption,
            .roomGuestAccess,
            .roomHistoryVisibility,
            .roomKey,
            .roomMessage,
            .roomMessageFeedback,
            .roomRedaction,
            .roomThirdPartyInvite,
            .roomTag,
            .presence,
            .typing,
            .newDevice,
            .callInvite,
            .callCandidates,
            .callAnswer,
            .callHangup,
            .receipt,
            .readMarker,
        ]
    }
    
    public init(identifier: String) {
        self = MXEventType.allStaticValues.first(where: { $0.identifier == identifier }) ?? .custom(identifier)
    }
    
    
    public static func ==(_ lhs: MXEventType, _ rhs: MXEventType) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public var hashValue: Int {
        return identifier.hashValue
    }
}


/// Types of messages
public enum MXMessageType {
    case text, emote, notice, image, audio, video, location, file
    case custom(String)
    
    var identifier: String {
        switch self {
        case .text: return kMXMessageTypeText
        case .emote: return kMXMessageTypeEmote
        case .notice: return kMXMessageTypeNotice
        case .image: return kMXMessageTypeImage
        case .audio: return kMXMessageTypeAudio
        case .video: return kMXMessageTypeVideo
        case .location: return kMXMessageTypeLocation
        case .file: return kMXMessageTypeFile
        case .custom(let value): return value
        }
    }
}


/// Membership definitions
public enum MXMembership {
    case unknown, invite, join, leave, ban
    
    var identifier: __MXMembership {
        switch self {
        case .unknown: return __MXMembershipUnknown
        case .invite: return __MXMembershipInvite
        case .join: return __MXMembershipJoin
        case .leave: return __MXMembershipLeave
        case .ban: return __MXMembershipBan
        }
    }
    
    init(identifier: __MXMembership) {
        let possibilities: [MXMembership] = [.unknown, .invite, .join, .leave, .ban]
        self = possibilities.first(where: { $0.identifier == identifier }) ?? .unknown
    }
}


public extension MXEvent {
    
    /**
     The string event (decrypted, if necessary) type as provided by the homeserver.
     Unlike 'eventType', this field is always filled even for custom events.
     
     If the event is encrypted and the decryption failed (check 'decryptionError' property),
     'type' will remain kMXEventTypeStringRoomEncrypted ("m.room.encrypted").
     */
    @nonobjc var type: MXEventType {
        guard let identifier = __type else { return .custom("unknown") }
        return MXEventType(identifier: identifier)
    }
    
    /**
     The string event (possibly encrypted) type as provided by the homeserver.
     Unlike 'wireEventType', this field is always filled even for custom events.
     
     Do not access this property directly unless you absolutely have to. Prefer to use the
     'eventType' property that manages decryption.
     */
    @nonobjc var wireType: MXEventType {
        guard let identifier = __wireType else { return .custom("unknown") }
        return MXEventType(identifier: identifier)
    }
}

