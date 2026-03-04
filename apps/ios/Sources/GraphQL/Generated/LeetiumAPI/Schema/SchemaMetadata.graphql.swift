// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

protocol LeetiumAPI_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == LeetiumAPI.SchemaMetadata {}

protocol LeetiumAPI_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == LeetiumAPI.SchemaMetadata {}

protocol LeetiumAPI_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == LeetiumAPI.SchemaMetadata {}

protocol LeetiumAPI_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == LeetiumAPI.SchemaMetadata {}

extension LeetiumAPI {
  typealias SelectionSet = LeetiumAPI_SelectionSet

  typealias InlineFragment = LeetiumAPI_InlineFragment

  typealias MutableSelectionSet = LeetiumAPI_MutableSelectionSet

  typealias MutableInlineFragment = LeetiumAPI_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      switch typename {
      case "AgentMutation": return LeetiumAPI.Objects.AgentMutation
      case "BoolResult": return LeetiumAPI.Objects.BoolResult
      case "ModelInfo": return LeetiumAPI.Objects.ModelInfo
      case "ModelQuery": return LeetiumAPI.Objects.ModelQuery
      case "MutationRoot": return LeetiumAPI.Objects.MutationRoot
      case "QueryRoot": return LeetiumAPI.Objects.QueryRoot
      case "SessionEntry": return LeetiumAPI.Objects.SessionEntry
      case "SessionQuery": return LeetiumAPI.Objects.SessionQuery
      case "StatusInfo": return LeetiumAPI.Objects.StatusInfo
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}