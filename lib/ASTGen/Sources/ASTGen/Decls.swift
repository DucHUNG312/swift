import CASTBridging

// Needed to use SyntaxTransformVisitor's visit method.
@_spi(SyntaxTransformVisitor)
import SwiftSyntax
import SwiftDiagnostics

// MARK: - TypeDecl

extension ASTGenVisitor {
  public func visit(_ node: TypeAliasDeclSyntax) -> ASTNode {
    let (name, nameLoc) = node.name.bridgedIdentifierAndSourceLoc(in: self)

    return .decl(
      TypeAliasDecl_create(
        self.ctx,
        self.declContext,
        self.bridgedSourceLoc(for: node.typealiasKeyword),
        name,
        nameLoc,
        self.visit(node.genericParameterClause)?.rawValue,
        self.bridgedSourceLoc(for: node.initializer.equal),
        self.visit(node.initializer.value).rawValue,
        self.visit(node.genericWhereClause)?.rawValue
      )
    )
  }

  public func visit(_ node: EnumDeclSyntax) -> ASTNode {
    let (name, nameLoc) = node.name.bridgedIdentifierAndSourceLoc(in: self)

    let decl = EnumDecl_create(
      self.ctx,
      self.declContext,
      self.bridgedSourceLoc(for: node.enumKeyword),
      name,
      nameLoc,
      self.visit(node.genericParameterClause)?.rawValue,
      self.visit(node.inheritanceClause?.inheritedTypes),
      self.visit(node.genericWhereClause)?.rawValue,
      BridgedSourceRange(startToken: node.memberBlock.leftBrace, endToken: node.memberBlock.rightBrace, in: self)
    )

    self.withDeclContext(decl.asDeclContext) {
      IterableDeclContext_setParsedMembers(self.visit(node.memberBlock.members), decl.asDecl)
    }

    return .decl(decl.asDecl)
  }

  public func visit(_ node: StructDeclSyntax) -> ASTNode {
    let (name, nameLoc) = node.name.bridgedIdentifierAndSourceLoc(in: self)

    let decl = StructDecl_create(
      self.ctx,
      self.declContext,
      self.bridgedSourceLoc(for: node.structKeyword),
      name,
      nameLoc,
      self.visit(node.genericParameterClause)?.rawValue,
      self.visit(node.inheritanceClause?.inheritedTypes),
      self.visit(node.genericWhereClause)?.rawValue,
      BridgedSourceRange(startToken: node.memberBlock.leftBrace, endToken: node.memberBlock.rightBrace, in: self)
    )

    self.withDeclContext(decl.asDeclContext) {
      IterableDeclContext_setParsedMembers(self.visit(node.memberBlock.members), decl.asDecl)
    }

    return .decl(decl.asDecl)
  }

  public func visit(_ node: ClassDeclSyntax) -> ASTNode {
    let (name, nameLoc) = node.name.bridgedIdentifierAndSourceLoc(in: self)

    let decl = ClassDecl_create(
      self.ctx,
      self.declContext,
      self.bridgedSourceLoc(for: node.classKeyword),
      name,
      nameLoc,
      self.visit(node.genericParameterClause)?.rawValue,
      self.visit(node.inheritanceClause?.inheritedTypes),
      self.visit(node.genericWhereClause)?.rawValue,
      BridgedSourceRange(startToken: node.memberBlock.leftBrace, endToken: node.memberBlock.rightBrace, in: self),
      false
    )

    self.withDeclContext(decl.asDeclContext) {
      IterableDeclContext_setParsedMembers(self.visit(node.memberBlock.members), decl.asDecl)
    }

    return .decl(decl.asDecl)
  }

  public func visit(_ node: ActorDeclSyntax) -> ASTNode {
    let (name, nameLoc) = node.name.bridgedIdentifierAndSourceLoc(in: self)

    let decl = ClassDecl_create(
      self.ctx,
      self.declContext,
      self.bridgedSourceLoc(for: node.actorKeyword),
      name,
      nameLoc,
      self.visit(node.genericParameterClause)?.rawValue,
      self.visit(node.inheritanceClause?.inheritedTypes),
      self.visit(node.genericWhereClause)?.rawValue,
      BridgedSourceRange(startToken: node.memberBlock.leftBrace, endToken: node.memberBlock.rightBrace, in: self),
      true
    )

    self.withDeclContext(decl.asDeclContext) {
      IterableDeclContext_setParsedMembers(self.visit(node.memberBlock.members), decl.asDecl)
    }

    return .decl(decl.asDecl)
  }

  func visit(_ node: ProtocolDeclSyntax) -> ASTNode {
    let (name, nameLoc) = node.name.bridgedIdentifierAndSourceLoc(in: self)
    let primaryAssociatedTypeNames = node.primaryAssociatedTypeClause?.primaryAssociatedTypes.lazy.map {
      $0.name.bridgedIdentifierAndSourceLoc(in: self) as BridgedIdentifierAndSourceLoc
    }

    let decl = ProtocolDecl_create(
      self.ctx,
      self.declContext,
      self.bridgedSourceLoc(for: node.protocolKeyword),
      name,
      nameLoc,
      primaryAssociatedTypeNames.bridgedArray(in: self),
      self.visit(node.inheritanceClause?.inheritedTypes),
      self.visit(node.genericWhereClause)?.rawValue,
      BridgedSourceRange(startToken: node.memberBlock.leftBrace, endToken: node.memberBlock.rightBrace, in: self)
    )

    self.withDeclContext(decl.asDeclContext) {
      IterableDeclContext_setParsedMembers(self.visit(node.memberBlock.members), decl.asDecl)
    }

    return .decl(decl.asDecl)
  }

  func visit(_ node: AssociatedTypeDeclSyntax) -> ASTNode {
    let (name, nameLoc) = node.name.bridgedIdentifierAndSourceLoc(in: self)

    return .decl(
      AssociatedTypeDecl_create(
        self.ctx,
        self.declContext,
        self.bridgedSourceLoc(for: node.associatedtypeKeyword),
        name,
        nameLoc,
        self.visit(node.inheritanceClause?.inheritedTypes),
        self.visit(node.initializer?.value)?.rawValue,
        self.visit(node.genericWhereClause)?.rawValue
      )
    )
  }
}

// MARK: - ExtensionDecl

extension ASTGenVisitor {
  func visit(_ node: ExtensionDeclSyntax) -> ASTNode {
    let decl = ExtensionDecl_create(
      self.ctx,
      self.declContext,
      self.bridgedSourceLoc(for: node.extensionKeyword),
      self.visit(node.extendedType).rawValue,
      self.visit(node.inheritanceClause?.inheritedTypes),
      self.visit(node.genericWhereClause)?.rawValue,
      BridgedSourceRange(startToken: node.memberBlock.leftBrace, endToken: node.memberBlock.rightBrace, in: self)
    )

    self.withDeclContext(decl.asDeclContext) {
      IterableDeclContext_setParsedMembers(self.visit(node.memberBlock.members), decl.asDecl)
    }

    return .decl(decl.asDecl)
  }
}

// MARK: - EnumCaseDecl

extension ASTGenVisitor {
  func visit(_ node: EnumCaseElementSyntax) -> ASTNode {
    let (name, nameLoc) = node.name.bridgedIdentifierAndSourceLoc(in: self)

    return .decl(
      EnumElementDecl_create(
        self.ctx,
        self.declContext,
        name,
        nameLoc,
        self.visit(node.parameterClause)?.rawValue,
        self.bridgedSourceLoc(for: node.rawValue?.equal),
        self.visit(node.rawValue?.value)?.rawValue
      )
    )
  }

  func visit(_ node: EnumCaseDeclSyntax) -> ASTNode {
    .decl(
      EnumCaseDecl_create(
        self.declContext,
        self.bridgedSourceLoc(for: node.caseKeyword),
        node.elements.lazy.map { self.visit($0).rawValue }.bridgedArray(in: self)
      )
    )
  }
}

// MARK: - AbstractStorageDecl

extension ASTGenVisitor {
  public func visit(_ node: VariableDeclSyntax) -> ASTNode {
    let pattern = visit(node.bindings.first!.pattern).rawValue
    let initializer = visit(node.bindings.first!.initializer!).rawValue

    let isStatic = false  // TODO: compute this
    let isLet = node.bindingSpecifier.tokenKind == .keyword(.let)

    return .decl(
      VarDecl_create(
        self.ctx,
        self.declContext,
        self.bridgedSourceLoc(for: node.bindingSpecifier),
        pattern,
        initializer,
        isStatic,
        isLet
      )
    )
  }
}

// MARK: - AbstractFunctionDecl

extension ASTGenVisitor {
  public func visit(_ node: FunctionDeclSyntax) -> ASTNode {
    // FIXME: Compute this location
    let staticLoc: BridgedSourceLoc = nil

    let (name, nameLoc) = node.name.bridgedIdentifierAndSourceLoc(in: self)

    let decl = FuncDecl_create(
      self.ctx,
      self.declContext,
      staticLoc,
      self.bridgedSourceLoc(for: node.funcKeyword),
      name,
      nameLoc,
      self.visit(node.genericParameterClause)?.rawValue,
      self.visit(node.signature.parameterClause).rawValue,
      self.bridgedSourceLoc(for: node.signature.effectSpecifiers?.asyncSpecifier),
      self.bridgedSourceLoc(for: node.signature.effectSpecifiers?.throwsSpecifier),
      self.visit(node.signature.returnClause?.type)?.rawValue,
      self.visit(node.genericWhereClause)?.rawValue
    )

    if let body = node.body {
      self.withDeclContext(decl.asDeclContext) {
        AbstractFunctionDecl_setBody(self.visit(body).rawValue, decl.asDecl)
      }
    }

    return .decl(decl.asDecl)
  }

  func visit(_ node: InitializerDeclSyntax) -> ASTNode {
    let decl = ConstructorDecl_create(
      self.ctx,
      self.declContext,
      self.bridgedSourceLoc(for: node.initKeyword),
      self.bridgedSourceLoc(for: node.optionalMark),
      node.optionalMark?.tokenKind == .exclamationMark,
      self.visit(node.genericParameterClause)?.rawValue,
      self.visit(node.signature.parameterClause).rawValue,
      self.bridgedSourceLoc(for: node.signature.effectSpecifiers?.asyncSpecifier),
      self.bridgedSourceLoc(for: node.signature.effectSpecifiers?.throwsSpecifier),
      self.visit(node.genericWhereClause)?.rawValue
    )

    if let body = node.body {
      self.withDeclContext(decl.asDeclContext) {
        AbstractFunctionDecl_setBody(self.visit(body).rawValue, decl.asDecl)
      }
    }

    return .decl(decl.asDecl)
  }

  func visit(_ node: DeinitializerDeclSyntax) -> ASTNode {
    let decl = DestructorDecl_create(
      self.ctx,
      self.declContext,
      self.bridgedSourceLoc(for: node.deinitKeyword)
    )

    if let body = node.body {
      self.withDeclContext(decl.asDeclContext) {
        AbstractFunctionDecl_setBody(self.visit(body).rawValue, decl.asDecl)
      }
    }

    return .decl(decl.asDecl)
  }
}

// MARK: - OperatorDecl

extension BridgedOperatorFixity {
  fileprivate init?(from tokenKind: TokenKind) {
    switch tokenKind {
    case .keyword(.infix): self = .infix
    case .keyword(.prefix): self = .prefix
    case .keyword(.postfix): self = .postfix
    default: return nil
    }
  }
}

extension ASTGenVisitor {
  func visit(_ node: OperatorDeclSyntax) -> ASTNode {
    let (name, nameLoc) = node.name.bridgedIdentifierAndSourceLoc(in: self)
    let (precedenceGroupName, precedenceGroupLoc) = (node.operatorPrecedenceAndTypes?.precedenceGroup).bridgedIdentifierAndSourceLoc(in: self)

    let fixity: BridgedOperatorFixity
    if let value = BridgedOperatorFixity(from: node.fixitySpecifier.tokenKind) {
      fixity = value
    } else {
      fixity = .infix
      self.diagnose(Diagnostic(node: node.fixitySpecifier, message: UnexpectedTokenKindError(token: node.fixitySpecifier)))
    }

    return .decl(
      OperatorDecl_create(
        self.ctx,
        self.declContext,
        fixity,
        self.bridgedSourceLoc(for: node.operatorKeyword),
        name,
        nameLoc,
        self.bridgedSourceLoc(for: node.operatorPrecedenceAndTypes?.colon),
        precedenceGroupName,
        precedenceGroupLoc
      )
    )
  }
}

// MARK: - ImportDecl

extension BridgedImportKind {
  fileprivate init?(from tokenKind: TokenKind) {
    switch tokenKind {
    case .keyword(.typealias): self = .type
    case .keyword(.struct): self = .struct
    case .keyword(.class): self = .class
    case .keyword(.enum): self = .enum
    case .keyword(.protocol): self = .protocol
    case .keyword(.var), .keyword(.let): self = .var
    case .keyword(.func): self = .func
    default: return nil
    }
  }
}

extension ASTGenVisitor {
  func visit(_ node: ImportDeclSyntax) -> ASTNode {
    let importKind: BridgedImportKind
    if let specifier = node.importKindSpecifier {
      if let value = BridgedImportKind(from: specifier.tokenKind) {
        importKind = value
      } else {
        self.diagnose(Diagnostic(node: specifier, message: UnexpectedTokenKindError(token: specifier)))
        importKind = .module
      }
    } else {
      importKind = .module
    }

    return .decl(
      ImportDecl_create(
        self.ctx,
        self.declContext,
        self.bridgedSourceLoc(for: node.importKeyword),
        importKind,
        self.bridgedSourceLoc(for: node.importKindSpecifier),
        node.path.lazy.map {
          $0.name.bridgedIdentifierAndSourceLoc(in: self) as BridgedIdentifierAndSourceLoc
        }.bridgedArray(in: self)
      )
    )
  }
}

extension ASTGenVisitor {
  @inline(__always)
  func visit(_ node: MemberBlockItemListSyntax) -> BridgedArrayRef {
    node.lazy.map { self.visit($0).rawValue }.bridgedArray(in: self)
  }

  @inline(__always)
  func visit(_ node: InheritedTypeListSyntax) -> BridgedArrayRef {
    node.lazy.map { self.visit($0.type).rawValue }.bridgedArray(in: self)
  }
}
