unit dla.Classes;

interface

uses
  System.SysUtils, System.Classes, System.JSON;

type
  EJsonRpcParse = class abstract(Exception);

  TCustomJsonClass = class
  protected
    FJson: TJSONObject;

    constructor Create(Json: TJSONObject); overload; virtual;
    constructor Create; overload; virtual;

    function RemovePair(const Str: string): TJSONPair;
    function AddPair(const Str: string; const Val: TJSONValue): TJSONObject; overload;
    function AddPair(const Str: string; const Val: string): TJSONObject; overload;
    function AddPair(const Str: string; const Val: Boolean): TJSONObject; overload;
    function AddPair(const Str: string; const Val: Integer): TJSONObject; overload;
    function SetPair(const Str: string; const Val: TJSONValue): TJSONObject; overload;
    function SetPair(const Str: string; const Val: string): TJSONObject; overload;
    function SetPair(const Str: string; const Val: Boolean): TJSONObject; overload;
    function SetPair(const Str: string; const Val: Integer): TJSONObject; overload;
    function GetValue(const Name: string): TJSONValue; overload;
    function GetText(const Name: string): string; overload;
    function GetBoolean(const Name: string): Boolean; overload;
  public
    property Json: TJSONObject read FJson;
  end;

  TMessage = class abstract(TCustomJsonClass)
  protected
    constructor Create(Json: TJSONObject); overload; override;
    constructor Create; overload; override;
  end;

  TParams = class abstract(TCustomJsonClass);
  TClassOfParams = class of TParams;

  TMessageRequest = class abstract(TMessage)
  protected
    class function GetMethod: String; virtual; abstract;
    constructor Create; override;
    constructor Create(Json: TJSONObject); override;
  public
    constructor Create(ID: Integer); overload;
    constructor Create(ID: String); overload;

    property Method: String read GetMethod;
  end;

  TMessageResponse = class abstract(TMessage)
  type
    TResponseError = class(TCustomJsonClass)
    type
      TErrorCodes = (
        ecParseError = -32700,
        ecInvalidRequest = -32600,
        ecMethodNotFound = -32601,
        ecInvalidParams = -32602,
        ecInternalError = -32603,
        ecServerErrorStart = -32099,
        ecServerNotInitialized = -32002,
        ecUnknownErrorCode = -32001,
        ecServerErrorEnd = -32000,
        ecContentModified = -32801,
        ecRequestCancelled = -32800,
        ecReservedErrorRangeStart = -32899
      );
    private
      FData: TJSONValue;
      function GetCode: TErrorCodes;
      function GetMessage: String;
        procedure SetData(const Value: TJSONValue);
    public
      constructor Create(Json: TJSONObject); override;

      property Code: TErrorCodes read GetCode;
      property Message: String read GetMessage;
      property Data: TJSONValue read FData write SetData;
    end;
  private
    FError: TResponseError;
    function GetID: TJSONValue;
    procedure SetID(const Value: TJSONValue);
    procedure SetResult(const Value: TJSONValue);
    function GetResult: TJSONValue;
  public
    constructor Create(Json: TJSONObject); override;
    constructor Create; override;
    constructor Create(ID: Integer); overload;
    constructor Create(ID: String); overload;

    property ID: TJSONValue read GetID write SetID;
    property Result: TJSONValue read GetResult write SetResult;
    property Error: TResponseError read FError;
  end;

  TMessageNotification = class abstract(TMessage)
  protected
    class function GetMethod: String; virtual; abstract;
    constructor Create; override;
    constructor Create(Json: TJSONObject); override;
  public
    property Method: String read GetMethod;
  end;

  TCancellationNotification = class (TMessageNotification)
  type
    TCancelParams = class(TParams)
    private
      function GetID: TJSONValue;
      procedure SetID(const Value: TJSONValue);
    public
      constructor Create(Json: TJSONObject); override;
      constructor Create; override;

      property ID: TJSONValue read GetID write SetID;
    end;
  private
    FParams: TCancelParams;
  protected
    class function GetMethod: String; override;
  public
    constructor Create(Json: TJSONObject); override;
    constructor Create; override;

    property Params: TCancelParams read FParams;
  end;

  TProgressNotification = class (TMessageNotification)
  type
    TProgressParams = class(TParams)
    private
      function GetToken: TJSONValue;
      function GetValue: TJSONValue;
      procedure SetToken(const Value: TJSONValue);
      procedure SetValue(const Value: TJSONValue);
    public
      constructor Create(Json: TJSONObject); override;
      constructor Create; override;

      property Token: TJSONValue read GetToken write SetToken;
      property Value: TJSONValue read GetValue write SetValue;
    end;
  private
    FParams: TProgressParams;
  protected
    class function GetMethod: String; override;
  public
    constructor Create(Json: TJSONObject); override;
    constructor Create; override;

    property Params: TProgressParams read FParams;
  end;

  TDocumentUri = type string;
  TURI = type string;

  TRegularExpressionsClientCapabilities = class(TCustomJsonClass)
  private
    function GetEngine: string;
    function GetVersion: TJSONString;
  public
    property Engine: string read GetEngine;
    property Version: TJSONString read GetVersion;
  end;

  TPosition = class(TCustomJsonClass)
  private
    function GetLine: Cardinal;
    function GetCharacter: Cardinal;
    procedure SetCharacter(const Value: Cardinal);
    procedure SetLine(const Value: Cardinal);
  public
    constructor Create; override;

    property Line: Cardinal read GetLine write SetLine;
    property Character: Cardinal read GetCharacter write SetCharacter;
  end;

  TRange = class(TCustomJsonClass)
  private
    FStart: TPosition;
    FEnd: TPosition;
  public
    constructor Create(Json: TJSONObject); override;
    constructor Create; override;

    property Start: TPosition read FStart;
    property &End: TPosition read FEnd;
  end;

  TLocation = class(TCustomJsonClass)
  private
    FUri: TDocumentUri;
    FRange: TRange;
    procedure SetUri(const Value: TDocumentUri);
  public
    constructor Create(Json: TJSONObject); override;
    constructor Create; override;

    property Uri: TDocumentUri read FUri write SetUri;
    property Range: TRange read FRange;
  end;

  TLocationLink = class(TCustomJsonClass)
  private
    FOriginSelectionRange: TRange;
    FTargetSelectionRange: TRange;
    FTargetUri: TDocumentUri;
    FTargetRange: TRange;
    procedure SetOriginSelectionRange(const Value: TRange);
    procedure SetTargetUri(const Value: TDocumentUri);
  public
    constructor Create(Json: TJSONObject); override;
    constructor Create; override;

    property OriginSelectionRange: TRange read FOriginSelectionRange write SetOriginSelectionRange;
    property TargetUri: TDocumentUri read FTargetUri write SetTargetUri;
    property TargetRange: TRange read FTargetRange;
    property TargetSelectionRange: TRange read FTargetSelectionRange;
  end;

  TDiagnostics = class(TCustomJsonClass)
  type
    TDiagnosticSeverity = (
      dsUnknown = 0,
      dsError = 1,
      dsWarning = 2,
      dsInformation = 3,
      dsHint = 4
    );

    TDiagnosticTag = (
      dtUnknown = 0,
      dtUnnecessary = 1,
      dtDeprecated = 2
    );
    TArrayOfDiagnosticTag = array of TDiagnosticTag;
  private
    FRange: TRange;
(*
    FSeverity?: TDiagnosticSeverity;
    FCode?: integer | string;
    FCodeDescription?: CodeDescription;
    FSource?: string;
*)
(*
    FTags?: TArrayOfDiagnosticTag;
    FRelatedInformation?: DiagnosticRelatedInformation[];
    FData?: unknown;
*)
    function GetMessage: String;
    procedure SetMessage(const Value: String);
  public
    constructor Create(Json: TJSONObject); override;
    constructor Create; override;

    property Range: TRange read FRange;
    property Message: String read GetMessage write SetMessage;
  end;

  TCommand = class(TCustomJsonClass)
  private
    procedure SetTitle(const Value: String);
    procedure SetCommand(const Value: String);
    function GetTitle: String;
    function GetCommand: String;
  protected
    constructor Create(Json: TJSONObject); override;
    constructor Create; override;

    property Title: String read GetTitle write SetTitle;
    property Command: String read GetCommand write SetCommand;
  end;

  TTextEdit = class(TCustomJsonClass)
  private
    FRange: TRange;
    function GetNewText: String;
    procedure SetNewText(const Value: String);
  protected
    constructor Create(Json: TJSONObject); override;
    constructor Create; override;

    property Range: TRange read FRange;
    property NewText: String read GetNewText write SetNewText;
  end;

(*
  TChangeAnnotation = class
    label: string;
    needsConfirmation?: Boolean;
    description?: string;
  end;

  type TChangeAnnotationIdentifier = string;

  TAnnotatedTextEdit = class(TTextEdit)
    annotationId: TChangeAnnotationIdentifier;
  end;

  TTextDocumentEdit = class
    textDocument: OptionalVersionedTextDocumentIdentifier;
    edits: (TextEdit | AnnotatedTextEdit)[];
  end;

  TCreateFileOptions = class
    overwrite?: Boolean;
    ignoreIfExists?: Boolean;
  end;

  TCreateFile = class
    kind: 'create';
    uri: DocumentUri;
    options?: CreateFileOptions;
    annotationId?: TChangeAnnotationIdentifier;
  end;

  TRenameFileOptions = class
    overwrite?: Boolean;
    ignoreIfExists?: Boolean;
  end;

  TRenameFile = class
    kind: 'rename';
    oldUri: DocumentUri;
    newUri: DocumentUri;
    options?: RenameFileOptions;
    annotationId?: TChangeAnnotationIdentifier;
  end;

  TDeleteFileOptions = class
    recursive?: Boolean;
    ignoreIfNotExists?: Boolean;
  end;

  TDeleteFile = class
    kind: 'delete';
    uri: DocumentUri;
    options?: DeleteFileOptions;
    annotationId?: TChangeAnnotationIdentifier;
  end;

  TWorkspaceEdit = class
    changes?: class
      [uri: DocumentUri]: TextEdit[];
    end;
    documentChanges?: (
            TextDocumentEdit[] |
            (TextDocumentEdit | CreateFile | RenameFile | DeleteFile)[]
    );

    changeAnnotations?: begin
            [id: string (* TChangeAnnotationIdentifier * )]: ChangeAnnotation;
      end;
  end;

  TWorkspaceEditClientCapabilities = class
    documentChanges?: Boolean;
    resourceOperations?: ResourceOperationKind[];
    failureHandling?: FailureHandlingKind;
    normalizesLineEndings?: Boolean;
    changeAnnotationSupport?: begin
            groupsOnLabel?: Boolean;
      end;
  end;

  type ResourceOperationKind = 'create' | 'rename' | 'delete';

{
  namespace ResourceOperationKind {
    const Create: ResourceOperationKind = 'create';
    const Rename: ResourceOperationKind = 'rename';
    const Delete: ResourceOperationKind = 'delete';
  end;

  type FailureHandlingKind = 'abort' | 'transactional' | 'undo'
    | 'textOnlyTransactional';

  namespace FailureHandlingKind {
    const Abort: FailureHandlingKind = 'abort';
    const Transactional: FailureHandlingKind = 'transactional';
    const TextOnlyTransactional: FailureHandlingKind
            = 'textOnlyTransactional';
    const Undo: FailureHandlingKind = 'undo';
  end;
}

  TTextDocumentIdentifier = class
    uri: DocumentUri;
  end;

  TTextDocumentItem = class
    uri: DocumentUri;
    languageId: string;
    version: integer;
    text: string;
  end;

  TVersionedTextDocumentIdentifier = class(TTextDocumentIdentifier)
    version: integer;
  end;

  TOptionalVersionedTextDocumentIdentifier = class(TTextDocumentIdentifier)
    version: integer | null;
  end;

  TTextDocumentPositionParams = class
    textDocument: TextDocumentIdentifier;
    position: Position;
  end;

  TDocumentFilter = class
    language?: string;
    scheme?: string;
    pattern?: string;
  end;

  TStaticRegistrationOptions = class
    id?: string;
  end;

  TTextDocumentRegistrationOptions = class
    documentSelector: DocumentSelector | null;
  end;
*)

  TMarkupKind = (mkPlainText, mkMarkDown);

  TMarkupContent = class(TCustomJsonClass)
  private
    function GetKind: TMarkupKind;
    function GetValue: String;
    procedure SetKind(const Value: TMarkupKind);
    procedure SetValue(const Value: String);
  public
    constructor Create; override;
    constructor Create(Json: TJSONObject); override;

    property Kind: TMarkupKind read GetKind write SetKind;
    property Value: String read GetValue write SetValue;
  end;

(*
  TMarkdownClientCapabilities = class
    parser: string;
    version?: string;
  end;
*)

  TWorkDoneProgress = class(TCustomJsonClass)
  private
    function GetMessage: string;
    procedure SetMessage(const Value: string);
  protected
    class function GetKind: String; virtual; abstract;
  public
    property Message: string read GetMessage write SetMessage;
  end;

  TWorkDoneProgressBegin = class(TWorkDoneProgress)
  private
    function GetTitle: string;
    procedure SetTitle(const Value: string);
    function GetCancellable: Boolean;
    function GetPercentage: Cardinal;
    procedure SetCancellable(const Value: Boolean);
    procedure SetPercentage(const Value: Cardinal);
  protected
    class function GetKind: String; override;
  public
    constructor Create; override;

    property Title: string read GetTitle write SetTitle;
    property Cancellable: Boolean read GetCancellable write SetCancellable;
    property Percentage: Cardinal read GetPercentage write SetPercentage;
  end;

  TWorkDoneProgressReport = class(TWorkDoneProgress)
  protected
    class function GetKind: String; override;
(*
    cancellable?: Boolean;
    percentage?: uinteger;
*)
  end;

  TWorkDoneProgressEnd = class(TWorkDoneProgress)
  protected
    class function GetKind: String; override;
  end;

  TWorkDoneProgressParams = class(TParams)
  private
    function GetWorkDoneToken: TJSONValue;
    procedure SetWorkDoneToken(const Value: TJSONValue);
  public
    property WorkDoneToken: TJSONValue read GetWorkDoneToken write SetWorkDoneToken;
  end;

(*
  TWorkDoneProgressOptions = class
    workDoneProgress?: Boolean;
  end;

  TPartialResultParams = class
    partialResultToken?: ProgressToken;
  end;
*)

  TClientCapabilities = class;

  TMessageRequestInitialize = class(TMessageRequest)
  type
    TInitializeParams = class(TWorkDoneProgressParams)
    type
      TTraceValue = (tvOff, tvMessages, tvVerbose);

      TClientInfo = class(TCustomJsonClass)
      private
        function GetName: string;
        function GetVersion: string;
        procedure SetName(const Value: string);
        procedure SetVersion(const Value: string);
      public
        property Name: string read GetName write SetName;
        property Version: string read GetVersion write SetVersion;
      end;
    private
      FClientInfo: TClientInfo;
      FCapabilities: TClientCapabilities;
      function GetLocale: TJSONString;
      function GetProcessId: TJSONValue;
      function GetRootPath: TJSONString;
      function GetTraceValue: TTraceValue;
      procedure SetInitializationOptions(const Value: TJsonValue);
      procedure SetLocale(const Value: TJSONString);
      procedure SetProcessId(const Value: TJSONValue);
      procedure SetRootPath(const Value: TJSONString);
      procedure SetRootUri(const Value: TDocumentUri);
      procedure SetTraceValue(const Value: TTraceValue);
      function GetInitializationOptions: TJsonValue;
      function GetRootUri: TDocumentUri;

(*
      processId: integer | null;
      clientInfo?: TClientInfo
      locale?: string;
      rootPath?: string | null;
      rootUri: DocumentUri | null;
      initializationOptions?: any;
      capabilities: ClientCapabilities;
      trace?: TraceValue;
      workspaceFolders?: WorkspaceFolder[] | null;
*)
    public
      constructor Create; override;
      constructor Create(Json: TJSONObject); override;

      property ProcessId: TJSONValue read GetProcessId write SetProcessId;
      property ClientInfo: TClientInfo read FClientInfo;
      property Locale: TJSONString read GetLocale write SetLocale;
      property RootPath: TJSONString read GetRootPath write SetRootPath;
      property RootUri: TDocumentUri read GetRootUri write SetRootUri;
      property InitializationOptions: TJsonValue read GetInitializationOptions write SetInitializationOptions;
      property Capabilities: TClientCapabilities read FCapabilities;
      property Trace: TTraceValue read GetTraceValue write SetTraceValue;
//      property workspaceFolders?: WorkspaceFolder[] | nullreadwrite;
    end;
  private
    FParams: TInitializeParams;
  protected
    class function GetMethod: String; override;
  public
    constructor Create; override;
    constructor Create(Json: TJSONObject); override;

    property Params: TInitializeParams read FParams;
  end;

(*
  TTextDocumentClientCapabilities = class

    synchronization?: TextDocumentSyncClientCapabilities;
    completion?: CompletionClientCapabilities;
    hover?: HoverClientCapabilities;
    signatureHelp?: SignatureHelpClientCapabilities;
    declaration?: DeclarationClientCapabilities;
    definition?: DefinitionClientCapabilities;
    typeDefinition?: TypeDefinitionClientCapabilities;
    implementation?: ImplementationClientCapabilities;
    references?: ReferenceClientCapabilities;
    documentHighlight?: DocumentHighlightClientCapabilities;
    documentSymbol?: DocumentSymbolClientCapabilities;
    codeAction?: CodeActionClientCapabilities;
    codeLens?: CodeLensClientCapabilities;
    documentLink?: DocumentLinkClientCapabilities;
    colorProvider?: DocumentColorClientCapabilities;
    formatting?: DocumentFormattingClientCapabilities;
    rangeFormatting?: DocumentRangeFormattingClientCapabilities;
    onTypeFormatting?: DocumentOnTypeFormattingClientCapabilities;
    rename?: RenameClientCapabilities;
    publishDiagnostics?: PublishDiagnosticsClientCapabilities;
    foldingRange?: FoldingRangeClientCapabilities;
    selectionRange?: SelectionRangeClientCapabilities;
    linkedEditingRange?: LinkedEditingRangeClientCapabilities;
    callHierarchy?: CallHierarchyClientCapabilities;
    semanticTokens?: SemanticTokensClientCapabilities;
    moniker?: MonikerClientCapabilities;
  end;
*)

  TClientCapabilities = class(TCustomJsonClass)
  type
    TWorkspace = class(TCustomJsonClass)
    type
      TFileOperations = class(TCustomJsonClass)
      private
        function GetDidCreate: Boolean;
        function GetDidDelete: Boolean;
        function GetDidRename: Boolean;
        function GetDynamicRegistration: Boolean;
        function GetWillCreate: Boolean;
        function GetWillDelete: Boolean;
        function GetWillRename: Boolean;
        procedure SetDidCreate(const Value: Boolean);
        procedure SetDidDelete(const Value: Boolean);
        procedure SetDidRename(const Value: Boolean);
        procedure SetDynamicRegistration(const Value: Boolean);
        procedure SetWillCreate(const Value: Boolean);
        procedure SetWillDelete(const Value: Boolean);
        procedure SetWillRename(const Value: Boolean);
      public
        property DynamicRegistration: Boolean read GetDynamicRegistration write SetDynamicRegistration;
        property DidCreate: Boolean read GetDidCreate write SetDidCreate;
        property WillCreate: Boolean read GetWillCreate write SetWillCreate;
        property DidRename: Boolean read GetDidRename write SetDidRename;
        property WillRename: Boolean read GetWillRename write SetWillRename;
        property DidDelete: Boolean read GetDidDelete write SetDidDelete;
        property WillDelete: Boolean read GetWillDelete write SetWillDelete;
      end;

    private
      FFileOperations: TFileOperations;
      function GetApplyEdit: Boolean;
      procedure SetApplyEdit(const Value: Boolean);
      procedure SetFileOperations(const Value: TFileOperations);
    public
      property ApplyEdit: Boolean read GetApplyEdit write SetApplyEdit;
(*
      property WorkspaceEdit?: WorkspaceEditClientCapabilities;
      property DidChangeConfiguration?: DidChangeConfigurationClientCapabilities;
      property DidChangeWatchedFiles?: DidChangeWatchedFilesClientCapabilities;
      property Symbol?: WorkspaceSymbolClientCapabilities;
      property ExecuteCommand?: ExecuteCommandClientCapabilities;
      property WorkspaceFolders?: Boolean;
      property Configuration?: Boolean;
      property SemanticTokens?: SemanticTokensWorkspaceClientCapabilities;
      property CodeLens?: CodeLensWorkspaceClientCapabilities;
*)
      property FileOperations: TFileOperations read FFileOperations write SetFileOperations;
    end;

  private
    FWorkspace: TWorkspace;
    function GetExperimental: TJSONValue;
    procedure SetExperimental(const Value: TJSONValue);
    procedure SetWorkspace(const Value: TWorkspace);
  protected
  public
    property Workspace: TWorkspace read FWorkspace write SetWorkspace;
(*
    textDocument?: TextDocumentClientCapabilities;

    window?: class
      workDoneProgress?: Boolean;
      showMessage?: ShowMessageRequestClientCapabilities;
      showDocument?: ShowDocumentClientCapabilities;
    end;

    general?: {
            staleRequestSupport?: {
                    cancel: Boolean;
                     retryOnContentModified: string[];
              end;

            regularExpressions?: RegularExpressionsClientCapabilities;

            markdown?: MarkdownClientCapabilities;
      end;
*)
    property Experimental: TJSONValue read GetExperimental write SetExperimental;
  end;

  TServerCapabilities = class;

  TInitializeResult = class(TCustomJsonClass)
  type
    TServerInfo = class(TCustomJsonClass)
    private
      function GetName: string;
      function GetVersion: string;
      procedure SetName(const Value: string);
      procedure SetVersion(const Value: string);
    public
      property Name: string read GetName write SetName;
      property Version: string read GetVersion write SetVersion;
    end;
  private
    FCapabilities: TServerCapabilities;
    FServerInfo: TServerInfo;
    procedure SetServerInfo(const Value: TServerInfo);
  public
    constructor Create; override;
    constructor Create(Json: TJSONObject); override;

    property Capabilities: TServerCapabilities read FCapabilities;
    property ServerInfo: TServerInfo read FServerInfo write SetServerInfo;
  end;

(*
  namespace InitializeError {
    const unknownProtocolVersion: 1 = 1;
  end;

  TInitializeError = class
    retry: Boolean;
  end;
*)

  TServerCapabilities = class(TCustomJsonClass)
  private
    function GetExperimental: TJSONValue;
    procedure SetExperimental(const Value: TJSONValue);
  public
(*
    textDocumentSync?: TextDocumentSyncOptions | TextDocumentSyncKind;

    completionProvider?: CompletionOptions;

    hoverProvider?: Boolean | HoverOptions;

    signatureHelpProvider?: SignatureHelpOptions;

    declarationProvider?: Boolean | DeclarationOptions
            | DeclarationRegistrationOptions;

    definitionProvider?: Boolean | DefinitionOptions;

    typeDefinitionProvider?: Boolean | TypeDefinitionOptions
            | TypeDefinitionRegistrationOptions;

    implementationProvider?: Boolean | ImplementationOptions
            | ImplementationRegistrationOptions;

    referencesProvider?: Boolean | ReferenceOptions;

    documentHighlightProvider?: Boolean | DocumentHighlightOptions;

    documentSymbolProvider?: Boolean | DocumentSymbolOptions;

    codeActionProvider?: Boolean | CodeActionOptions;

    codeLensProvider?: CodeLensOptions;

    documentLinkProvider?: DocumentLinkOptions;

    colorProvider?: Boolean | DocumentColorOptions
            | DocumentColorRegistrationOptions;

    documentFormattingProvider?: Boolean | DocumentFormattingOptions;

    documentRangeFormattingProvider?: Boolean | DocumentRangeFormattingOptions;

    documentOnTypeFormattingProvider?: DocumentOnTypeFormattingOptions;

    renameProvider?: Boolean | RenameOptions;

    foldingRangeProvider?: Boolean | FoldingRangeOptions
            | FoldingRangeRegistrationOptions;

    executeCommandProvider?: ExecuteCommandOptions;

    selectionRangeProvider?: Boolean | SelectionRangeOptions
            | SelectionRangeRegistrationOptions;

    linkedEditingRangeProvider?: Boolean | LinkedEditingRangeOptions
            | LinkedEditingRangeRegistrationOptions;

    callHierarchyProvider?: Boolean | CallHierarchyOptions
            | CallHierarchyRegistrationOptions;

    semanticTokensProvider?: SemanticTokensOptions
            | SemanticTokensRegistrationOptions;

    monikerProvider?: Boolean | MonikerOptions | MonikerRegistrationOptions;

    workspaceSymbolProvider?: Boolean | WorkspaceSymbolOptions;

    workspace?: {
            workspaceFolders?: WorkspaceFoldersServerCapabilities;
            fileOperations?: {
                    didCreate?: FileOperationRegistrationOptions;
                    willCreate?: FileOperationRegistrationOptions;
                    didRename?: FileOperationRegistrationOptions;
                    willRename?: FileOperationRegistrationOptions;
                    didDelete?: FileOperationRegistrationOptions;
                    willDelete?: FileOperationRegistrationOptions;
              end;
      end;
*)
    property Experimental: TJSONValue read GetExperimental write SetExperimental;
  end;

  TMessageNotificationInitialized = class(TMessageNotification)
  protected
    class function GetMethod: String; override;
  public
    constructor Create; override;
  end;

  TMessageRequestShutdown = class(TMessageRequest)
  protected
    class function GetMethod: String; override;
  public
    constructor Create; override;
  end;

  TMessageNotificationExit = class(TMessageNotification)
  protected
    class function GetMethod: String; override;
  public
    constructor Create; override;
  end;

  TMessageNotificationLogTrace = class(TMessageNotification)
  type
    TLogTraceParams = class(TParams)
    private
      function GetMessage: string;
      function GetVerbose: TJSONString;
      procedure SetMessage(const Value: string);
      procedure SetVerbose(const Value: TJSONString);
    public
      constructor Create(Json: TJSONObject); override;
      constructor Create; override;

      property Message: string read GetMessage write SetMessage;
      property Verbose: TJSONString read GetVerbose write SetVerbose;
    end;
  private
    FParams: TLogTraceParams;
  protected
    class function GetMethod: String; override;
  public
    constructor Create; override;
    constructor Create(Json: TJSONObject); override;

    property Params: TLogTraceParams read FParams;
  end;

  TMessageNotificationSetTrace = class(TMessageNotification)
  type
    TSetTraceParams = class(TParams)
    private
      function GetValue: string;
      procedure SetValue(const Value: string);
    public
      constructor Create(Json: TJSONObject); override;
      constructor Create; override;

      property Value: string read GetValue write SetValue;
    end;
  private
    FParams: TSetTraceParams;
  protected
    class function GetMethod: String; override;
  public
    constructor Create; override;
    constructor Create(Json: TJSONObject); override;

    property Params: TSetTraceParams read FParams;
  end;

(*
  TShowMessageParams = class
    type: MessageType;
    message: string;
  end;

  namespace MessageType {
    const Error = 1;
    const Warning = 2;
    const Info = 3;
    const Log = 4;
  end;

  type MessageType = 1 | 2 | 3 | 4;

  TShowMessageRequestClientCapabilities = class
    messageActionItem?: {
            additionalPropertiesSupport?: Boolean;
      end;
  end;

  TShowMessageRequestParams = class
    type: MessageType;
    message: string;
    actions?: MessageActionItem[];
  end;

  TMessageActionItem = class
    title: string;
  end;


  TShowDocumentClientCapabilities = class
    support: Boolean;
  end;

  TShowDocumentParams = class
    uri: URI;
    external?: Boolean;
    takeFocus?: Boolean;
    selection?: Range;
  end;

  TShowDocumentResult = class
    success: Boolean;
  end;

  TLogMessageParams = class
    type: MessageType;
    message: string;
  end;

  TWorkDoneProgressCreateParams = class
    token: ProgressToken;
  end;

  TWorkDoneProgressCancelParams = class
    token: ProgressToken;
  end;

  TRegistration = class
    id: string;
    method: string;
    registerOptions?: any;
  end;

  TRegistrationParams = class
    registrations: Registration[];
  end;
    id: string;
    method: string;
  end;

  TUnregistrationParams = class
    // This should correctly be named `unregistrations`. However changing this
    // is a breaking change and needs to wait until we deliver a 4.x version
    // of the specification.
    unregisterations: Unregistration[];
  end;

  TWorkspaceFoldersServerCapabilities = class
    supported?: Boolean;
    changeNotifications?: string | Boolean;
  end;

  TWorkspaceFolder = class
    uri: DocumentUri;
    name: string;
  end;

  TDidChangeWorkspaceFoldersParams = class
    event: WorkspaceFoldersChangeEvent;
  end;

  TWorkspaceFoldersChangeEvent = class
    added: WorkspaceFolder[];
    removed: WorkspaceFolder[];
  end;

  TDidChangeConfigurationClientCapabilities = class
    dynamicRegistration?: Boolean;
  end;

  TDidChangeConfigurationParams = class
    settings: any;
  end;

  TConfigurationParams = class
    items: ConfigurationItem[];
  end;

  TConfigurationItem = class
    scopeUri?: DocumentUri;
    section?: string;
  end;

  TDidChangeWatchedFilesClientCapabilities = class
    dynamicRegistration?: Boolean;
  end;

  TDidChangeWatchedFilesRegistrationOptions = class
    watchers: FileSystemWatcher[];
  end;

  TFileSystemWatcher = class
    globPattern: string;
    kind?: uinteger;
  end;

  namespace WatchKind {
    const Create = 1;
    const Change = 2;
    const Delete = 4;
  end;

  TDidChangeWatchedFilesParams = class
    changes: FileEvent[];
  end;

  TFileEvent = class
    uri: DocumentUri;
    type: uinteger;
  end;

  namespace FileChangeType {
    const Created = 1;
    const Changed = 2;
    const Deleted = 3;
  end;

  TWorkspaceSymbolClientCapabilities = class
    dynamicRegistration?: Boolean;
    symbolKind?: {
            valueSet?: SymbolKind[];
      end;
    tagSupport?: {
            valueSet: SymbolTag[];
      end;
  end;

  TWorkspaceSymbolOptions = class(TWorkDoneProgressOptions)
  end;

  TWorkspaceSymbolRegistrationOption= class
  s {(TWorkspaceSymbolOption)
  end;

  TWorkspaceSymbolParamss = class(TWorkDoneProgressParam)
    PartialResultParams {
    query: string;
  end;

  TExecuteCommandClientCapabilities = class
    dynamicRegistration?: Boolean;
  end;

  TExecuteCommandOptions = class(TWorkDoneProgressOptions)
    commands: string[];
  end;

  TExecuteCommandRegistrationOption= class
  s {(TExecuteCommandOption)
  end;

  TExecuteCommandParams = class(TWorkDoneProgressParams)
    command: string;
    arguments?: any[];
  end;

  TApplyWorkspaceEditParams = class
    label?: string;
    edit: WorkspaceEdit;
  end;

  TApplyWorkspaceEditResponse = class
    applied: Boolean;
    failureReason?: string;
    failedChange?: uinteger;
  end;

  TFileOperationRegistrationOptions = class
    filters: FileOperationFilter[];
  end;

  namespace FileOperationPatternKind {
    const file: 'file' = 'file';
    const folder: 'folder' = 'folder';
  end;

  type FileOperationPatternKind = 'file' | 'folder';

  TFileOperationPatternOptions = class
    ignoreCase?: Boolean;
  end;

  TFileOperationPattern = class
    glob: string;
    matches?: FileOperationPatternKind;
    options?: FileOperationPatternOptions;
  end;

  TFileOperationFilter = class
    scheme?: string;
    pattern: FileOperationPattern;
  end;

  TCreateFilesParams = class
    files: FileCreate[];
  end;

  TFileCreate = class
    uri: string;
  end;

  TRenameFilesParams = class
    files: FileRename[];
  end;

  TFileRename = class
    oldUri: string;
    newUri: string;
  end;

  TDeleteFilesParams = class
    files: FileDelete[];
  end;

  TFileDelete = class
    uri: string;
  end;

  namespace TextDocumentSyncKind {
    const None = 0;
    const Full = 1;
    const Incremental = 2;
  end;

  TTextDocumentSyncOptions = class
    openClose?: Boolean;
    change?: TextDocumentSyncKind;
  end;

  TDidOpenTextDocumentParams = class
    textDocument: TextDocumentItem;
  end;

  TTextDocumentChangeRegistrationOption= class
  s {(TTextDocumentRegistrationOption)
    syncKind: TextDocumentSyncKind;
  end;

  TDidChangeTextDocumentParams = class
    textDocument: VersionedTextDocumentIdentifier;
    contentChanges: TextDocumentContentChangeEvent[];
  end;

  type TextDocumentContentChangeEvent = {
    range: Range;
    rangeLength?: uinteger;
    text: string;
  end; | {
    text: string;
  end;

  TWillSaveTextDocumentParams = class
    textDocument: TextDocumentIdentifier;
    reason: TextDocumentSaveReason;
  end;

  namespace TextDocumentSaveReason {
    const Manual = 1;
    const AfterDelay = 2;
    const FocusOut = 3;
  end;

  type TextDocumentSaveReason = 1 | 2 | 3;

  TSaveOptions = class
    includeText?: Boolean;
  end;

  TTextDocumentSaveRegistrationOption = class(TTextDocumentRegistrationOption)
    includeText?: Boolean;
  end;

  TDidSaveTextDocumentParams = class
    textDocument: TextDocumentIdentifier;
    text?: string;
  end;

  TDidCloseTextDocumentParams = class
    textDocument: TextDocumentIdentifier;
  end;

  TTextDocumentSyncClientCapabilities = class
    dynamicRegistration?: Boolean;
    willSave?: Boolean;
    willSaveWaitUntil?: Boolean;
    didSave?: Boolean;
  end;

  namespace TextDocumentSyncKind {
    const None = 0;
    const Full = 1;
    const Incremental = 2;
  end;

  type TextDocumentSyncKind = 0 | 1 | 2;

  TTextDocumentSyncOptions = class
    openClose?: Boolean;
    change?: TextDocumentSyncKind;
    willSave?: Boolean;
    willSaveWaitUntil?: Boolean;
    save?: Boolean | SaveOptions;
  end;

  TPublishDiagnosticsClientCapabilities = class
    relatedInformation?: Boolean;
    tagSupport?: {
            valueSet: DiagnosticTag[];
      end;

    versionSupport?: Boolean;
    codeDescriptionSupport?: Boolean;
    dataSupport?: Boolean;
  end;

  TPublishDiagnosticsParams = class
    uri: DocumentUri;
    version?: uinteger;
    diagnostics: Diagnostic[];
  end;

  TCompletionClientCapabilities = class
    dynamicRegistration?: Boolean;
    completionItem?: {
            snippetSupport?: Boolean;
            commitCharactersSupport?: Boolean;
            documentationFormat?: MarkupKind[];
            deprecatedSupport?: Boolean;
            preselectSupport?: Boolean;
            tagSupport?: {
                    valueSet: CompletionItemTag[];
              end;
            insertReplaceSupport?: Boolean;
            resolveSupport?: {
                    properties: string[];
              end;

            insertTextModeSupport?: {
                    valueSet: InsertTextMode[];
              end;

            labelDetailsSupport?: Boolean;
      end;

    completionItemKind?: {
            valueSet?: CompletionItemKind[];
      end;

    contextSupport?: Boolean;

    insertTextMode?: InsertTextMode;
  end;

  TCompletionOptions = class(TWorkDoneProgressOptions)
    triggerCharacters?: string[];
    allCommitCharacters?: string[];

    resolveProvider?: Boolean;

    completionItem?: {
            labelDetailsSupport?: Boolean;
      end;
  end;

  TCompletionRegistrationOption= class extends TextDocumentRegistrationOptions, CompletionOptions {
  end;

  TCompletionParamss= class(TTextDocumentPositionParam)
    WorkDoneProgressParams, PartialResultParams {
    context?: CompletionContext;
  end;

  namespace CompletionTriggerKind {
    const Invoked: 1 = 1;
    const TriggerCharacter: 2 = 2;
    const TriggerForIncompleteCompletions: 3 = 3;
  end;
  type CompletionTriggerKind = 1 | 2 | 3;

  TCompletionContext = class
    triggerKind: CompletionTriggerKind;
    triggerCharacter?: string;
  end;

  TCompletionList = class
    isIncomplete: Boolean;

    items: CompletionItem[];
  end;

  namespace InsertTextFormat {
    const PlainText = 1;
    const Snippet = 2;
  end;

  type InsertTextFormat = 1 | 2;

  namespace CompletionItemTag {
    const Deprecated = 1;
  end;

  type CompletionItemTag = 1;

  TInsertReplaceEdit = class
    newText: string;
    insert: Range;
    replace: Range;
  end;

  namespace InsertTextMode {
    const asIs: 1 = 1;
    const adjustIndentation: 2 = 2;
  end;

  type InsertTextMode = 1 | 2;

  TCompletionItemLabelDetails = class
    parameters?: string;
    qualifier?: string;
    type?: string;
  end;

  TCompletionItem = class
    label: string;
    labelDetails?: CompletionItemLabelDetails;
    kind?: CompletionItemKind;
    tags?: CompletionItemTag[];
    detail?: string;
    documentation?: string | MarkupContent;
    deprecated?: Boolean;
    preselect?: Boolean;
    sortText?: string;
    filterText?: string;
    insertText?: string;
    insertTextFormat?: InsertTextFormat;
    insertTextMode?: InsertTextMode;
    textEdit?: TextEdit | InsertReplaceEdit;
    additionalTextEdits?: TextEdit[];
    commitCharacters?: string[];
    command?: Command;
    data?: any;
  end;

  namespace CompletionItemKind {
    const Text = 1;
    const Method = 2;
    const Function = 3;
    const Constructor = 4;
    const Field = 5;
    const Variable = 6;
    const 7= Class =
    const T= 8= class
    const Module = 9;
    const Property = 10;
    const Unit = 11;
    const Value = 12;
    const Enum = 13;
    const Keyword = 14;
    const Snippet = 15;
    const Color = 16;
    const File = 17;
    const Reference = 18;
    const Folder = 19;
    const EnumMember = 20;
    const Constant = 21;
    const Struct = 22;
    const Event = 23;
    const Operator = 24;
    const TypeParameter = 25;
  end;

  THoverClientCapabilities = class
    dynamicRegistration?: Boolean;
    contentFormat?: MarkupKind[];
  end;

  THoverOptions = class(TWorkDoneProgressOptions)
  end;

  THoverRegistrationOption= class
    extends TextDocumentRegistrationOptions, HoverOptions {
  end;

  THoverParamss= class(TTextDocumentPositionParam)
    WorkDoneProgressParams {
  end;

  THover = class
    contents: MarkedString | MarkedString[] | MarkupContent;
    range?: Range;
  end;

  type MarkedString = string | { language: string; value: string   end;

  TSignatureHelpClientCapabilities = class
    dynamicRegistration?: Boolean;
    signatureInformation?: {
            documentationFormat?: MarkupKind[];

            parameterInformation?: {
                    labelOffsetSupport?: Boolean;
              end;

            activeParameterSupport?: Boolean;
      end;

    contextSupport?: Boolean;
  end;

  TSignatureHelpOptions = class(TWorkDoneProgressOptions)
    triggerCharacters?: string[];
    retriggerCharacters?: string[];
  end;

  TSignatureHelpRegistrationOption= class
    extends TextDocumentRegistrationOptions, SignatureHelpOptions {
  end;

  TSignatureHelpParamss= class(TTextDocumentPositionParam)
    WorkDoneProgressParams {
    context?: SignatureHelpContext;
  end;

  namespace SignatureHelpTriggerKind {
    const Invoked: 1 = 1;
    const TriggerCharacter: 2 = 2;
    const ContentChange: 3 = 3;
  end;
  type SignatureHelpTriggerKind = 1 | 2 | 3;

  TSignatureHelpContext = class
    triggerKind: SignatureHelpTriggerKind;
    triggerCharacter?: string;
    isRetrigger: Boolean;
    activeSignatureHelp?: SignatureHelp;
  end;

  TSignatureHelp = class
    signatures: SignatureInformation[];
    activeSignature?: uinteger;
    activeParameter?: uinteger;
  end;

  TSignatureInformation = class
    label: string;
    documentation?: string | MarkupContent;
    parameters?: ParameterInformation[];
    activeParameter?: uinteger;
  end;

  TParameterInformation = class
    label: string | [uinteger, uinteger];
    documentation?: string | MarkupContent;
  end;

  TDeclarationClientCapabilities = class
    dynamicRegistration?: Boolean;
    linkSupport?: Boolean;
  end;

  TDeclarationOptions = class(TWorkDoneProgressOptions)
  end;

  TDeclarationRegistrationOptionss= class(TDeclarationOption)
    TextDocumentRegistrationOptions, StaticRegistrationOptions {
  end;

  TDeclarationParamss= class(TTextDocumentPositionParam)
    WorkDoneProgressParams, PartialResultParams {
  end;

  TDefinitionClientCapabilities = class
    dynamicRegistration?: Boolean;
    linkSupport?: Boolean;
  end;

  TDefinitionOptions = class(TWorkDoneProgressOptions)
  end;

  TDefinitionRegistrationOptions extend= class
    TextDocumentRegistrationOptions, DefinitionOptions {
  end;

  TDefinitionParamss = class(TTextDocumentPositionParam)
    WorkDoneProgressParams, PartialResultParams {
  end;

  TTypeDefinitionClientCapabilities = class
    dynamicRegistration?: Boolean;
    linkSupport?: Boolean;
  end;

  TTypeDefinitionOptions = class(TWorkDoneProgressOptions)
  end;

  TTypeDefinitionRegistrationOptions extend= class
    TextDocumentRegistrationOptions, TypeDefinitionOptions,
    StaticRegistrationOptions {
  end;

  TTypeDefinitionParamss= class(TTextDocumentPositionParam)
    WorkDoneProgressParams, PartialResultParams {
  end;

  TImplementationClientCapabilities = class
    dynamicRegistration?: Boolean;
    linkSupport?: Boolean;
  end;

  TImplementationOptions = class(TWorkDoneProgressOptions)
  end;

  TImplementationRegistrationOptions extend= class
    TextDocumentRegistrationOptions, ImplementationOptions,
    StaticRegistrationOptions {
  end;

  TImplementationParamss= class(TTextDocumentPositionParam)
    WorkDoneProgressParams, PartialResultParams {
  end;

  TReferenceClientCapabilities = class
    dynamicRegistration?: Boolean;
  end;

  TReferenceOptions = class(TWorkDoneProgressOptions)
  end;

  TReferenceRegistrationOptions = class(TextDocumentRegistrationOptions, ReferenceOptions
  end;

  TReferenceParams extends TextDocumentPositionParams= class
    WorkDoneProgressParams, PartialResultParams {
    context: ReferenceContext;
  end;

  TReferenceContext = class
    includeDeclaration: Boolean;
  end;

  TDocumentHighlightClientCapabilities = class
    dynamicRegistration?: Boolean;
  end;

  TDocumentHighlightOptions extends WorkDoneProgressOptions = class
  end;

  TDocumentHighlightRegistrationOptions extend= class
    TextDocumentRegistrationOptions, DocumentHighlightOptions {
  end;

  TDocumentHighlightParams extends TextDocumentPositionParams= class
    WorkDoneProgressParams, PartialResultParams {
  end;

  TDocumentHighlight = class
    range: Range;
    kind?: DocumentHighlightKind;
  end;

  namespace DocumentHighlightKind {
    const Text = 1;
    const Read = 2;
    const Write = 3;
  end;

  type DocumentHighlightKind = 1 | 2 | 3;

  TDocumentSymbolClientCapabilities = class
    dynamicRegistration?: Boolean;
    symbolKind?: {
            valueSet?: SymbolKind[];
      end;

    hierarchicalDocumentSymbolSupport?: Boolean;
    tagSupport?: {
            valueSet: SymbolTag[];
      end;

    labelSupport?: Boolean;
  end;

  TDocumentSymbolOptions extends WorkDoneProgressOptions = class
    label?: string;
  end;

  TDocumentSymbolRegistrationOptions extend= class
    TextDocumentRegistrationOptions, DocumentSymbolOptions {
  end;

  TDocumentSymbolParams extends WorkDoneProgressParams= class
    PartialResultParams {
    textDocument: TextDocumentIdentifier;
  end;

  namespace SymbolKind {
    const File = 1;
    const Module = 2;
    const Namespace = 3;
    const Package = 4;
    const 5= Class =
    const Method = 6;
    const Property = 7;
    const Field = 8;
    const Constructor = 9;
    const Enum = 10;
    const T= 11= class
    const Function = 12;
    const Variable = 13;
    const Constant = 14;
    const String = 15;
    const Number = 16;
    const Boolean = 17;
    const Array = 18;
    const Object = 19;
    const Key = 20;
    const Null = 21;
    const EnumMember = 22;
    const Struct = 23;
    const Event = 24;
    const Operator = 25;
    const TypeParameter = 26;
  end;

  namespace SymbolTag {
    const Deprecated: 1 = 1;
  end;

  type SymbolTag = 1;

  TDocumentSymbol = class

    name: string;
    detail?: string;
    kind: SymbolKind;
    tags?: SymbolTag[];
    deprecated?: Boolean;
    range: Range;
    selectionRange: Range;
    children?: DocumentSymbol[];
  end;

  TSymbolInformation = class
    name: string;
    kind: SymbolKind;
    tags?: SymbolTag[];
    deprecated?: Boolean;
    location: Location;
    containerName?: string;
  end;

  TCodeActionClientCapabilities = class
    dynamicRegistration?: Boolean;
    codeActionLiteralSupport?: {
            codeActionKind: {
                    valueSet: CodeActionKind[];
              end;
      end;
    isPreferredSupport?: Boolean;
    disabledSupport?: Boolean;
    dataSupport?: Boolean;
    resolveSupport?: {
            properties: string[];
      end;
    honorsChangeAnnotations?: Boolean;
  end;

  TCodeActionOptions extends WorkDoneProgressOptions = class
    codeActionKinds?: CodeActionKind[];
    resolveProvider?: Boolean;
  end;

  TCodeActionRegistrationOptions extend= class
    TextDocumentRegistrationOptions, CodeActionOptions {
  end;

  TCodeActionParams extends WorkDoneProgressParams= class
    PartialResultParams {
    textDocument: TextDocumentIdentifier;
    range: Range;
    context: CodeActionContext;
  end;

  type CodeActionKind = string;

  namespace CodeActionKind {
    const Empty: CodeActionKind = '';
    const QuickFix: CodeActionKind = 'quickfix';
    const Refactor: CodeActionKind = 'refactor';
    const RefactorExtract: CodeActionKind = 'refactor.extract';
    const RefactorInline: CodeActionKind = 'refactor.inline';
    const RefactorRewrite: CodeActionKind = 'refactor.rewrite';
    const Source: CodeActionKind = 'source';
    const SourceOrganizeImports: CodeActionKind =
            'source.organizeImports';
    const SourceFixAll: CodeActionKind = 'source.fixAll';
  end;

  TCodeActionContext = class
    diagnostics: Diagnostic[];
    only?: CodeActionKind[];
  end;

  TCodeAction = class
    title: string;
    kind?: CodeActionKind;
    diagnostics?: Diagnostic[];
    isPreferred?: Boolean;
    disabled?: {
            reason: string;
      end;
    edit?: WorkspaceEdit;
    command?: Command;
    data?: any;
  end;

  TCodeLensClientCapabilities = class
    dynamicRegistration?: Boolean;
  end;

  TCodeLensOptions extends WorkDoneProgressOptions = class
    resolveProvider?: Boolean;
  end;

  TCodeLensRegistrationOptions extend= class
    TextDocumentRegistrationOptions, CodeLensOptions {
  end;

  TCodeLensParams extends WorkDoneProgressParams, PartialResultParams = class
    textDocument: TextDocumentIdentifier;
  end;

  TCodeLens = class
    range: Range;
    command?: Command;
    data?: any;
  end;

  TCodeLensWorkspaceClientCapabilities = class
    refreshSupport?: Boolean;
  end;

  TDocumentLinkClientCapabilities = class
    dynamicRegistration?: Boolean;
    tooltipSupport?: Boolean;
  end;

  TDocumentLinkRegistrationOptions extend= class
    TextDocumentRegistrationOptions, DocumentLinkOptions {
  end;

  TDocumentLinkParams extends WorkDoneProgressParams= class
    PartialResultParams {
    textDocument: TextDocumentIdentifier;
  end;

  TDocumentLink = class
    range: Range;
    target?: DocumentUri;
    tooltip?: string;
    data?: any;
  end;

  TDocumentColorClientCapabilities = class
    dynamicRegistration?: Boolean;
  end;

  TDocumentColorOptions extends WorkDoneProgressOptions = class
  end;

  TDocumentColorRegistrationOptions extend= class
    TextDocumentRegistrationOptions, StaticRegistrationOptions,
    DocumentColorOptions {
  end;

  TDocumentColorParams extends WorkDoneProgressParams= class
    PartialResultParams {
    textDocument: TextDocumentIdentifier;
  end;

  TColorInformation = class
    range: Range;
    color: Color;
  end;

  TColor = class
    readonly red: decimal;
    readonly green: decimal;
    readonly blue: decimal;
    readonly alpha: decimal;
  end;

  TColorPresentationParams extends WorkDoneProgressParams= class
    PartialResultParams {
    textDocument: TextDocumentIdentifier;
    color: Color;
    range: Range;
  end;

  TColorPresentation = class
    label: string;
    textEdit?: TextEdit;
    additionalTextEdits?: TextEdit[];
  end;

  TDocumentFormattingClientCapabilities = class
    dynamicRegistration?: Boolean;
  end;

  TDocumentFormattingOptions extends WorkDoneProgressOptions = class
  end;

  TDocumentFormattingRegistrationOptions extend= class
    TextDocumentRegistrationOptions, DocumentFormattingOptions {
  end;

  TDocumentFormattingParams extends WorkDoneProgressParams = class
    textDocument: TextDocumentIdentifier;
    options: FormattingOptions;
  end;

  TFormattingOptions = class
    tabSize: uinteger;
    insertSpaces: Boolean;
    trimTrailingWhitespace?: Boolean;
    insertFinalNewline?: Boolean;
    trimFinalNewlines?: Boolean;
    [key: string]: Boolean | integer | string;
  end;

  TDocumentRangeFormattingClientCapabilities = class
    dynamicRegistration?: Boolean;
  end;

  TDocumentRangeFormattingOptions extend= class
    WorkDoneProgressOptions {
  end;

  TDocumentRangeFormattingRegistrationOptions extend= class
    TextDocumentRegistrationOptions, DocumentRangeFormattingOptions {
  end;


  TDocumentRangeFormattingParams extends WorkDoneProgressParams = class
    textDocument: TextDocumentIdentifier;
    range: Range;
    options: FormattingOptions;
  end;


  TDocumentOnTypeFormattingClientCapabilities = class
    dynamicRegistration?: Boolean;
  end;

  TDocumentOnTypeFormattingOptions = class
    firstTriggerCharacter: string;
    moreTriggerCharacter?: string[];
  end;

  TDocumentOnTypeFormattingRegistrationOptions extend= class
    TextDocumentRegistrationOptions, DocumentOnTypeFormattingOptions {
  end;


  TDocumentOnTypeFormattingParams extends TextDocumentPositionParams = class
    ch: string;
    options: FormattingOptions;
  end;


  namespace PrepareSupportDefaultBehavior {
     const Identifier: 1 = 1;
  end;

  TRenameClientCapabilities = class
    dynamicRegistration?: Boolean;
    prepareSupport?: Boolean;

    prepareSupportDefaultBehavior?: PrepareSupportDefaultBehavior;

    honorsChangeAnnotations?: Boolean;
  end;

  TRenameOptions extends WorkDoneProgressOptions = class
    prepareProvider?: Boolean;
  end;

  TRenameRegistrationOptions extend= class
    TextDocumentRegistrationOptions, RenameOptions {
  end;

  TRenameParams extends TextDocumentPositionParams= class
    WorkDoneProgressParams {
    newName: string;
  end;

  TPrepareRenameParams extends TextDocumentPositionParams = class
  end;


  TFoldingRangeClientCapabilities = class
    dynamicRegistration?: Boolean;
    rangeLimit?: uinteger;
    lineFoldingOnly?: Boolean;
  end;


  TFoldingRangeOptions extends WorkDoneProgressOptions = class
  end;


  TFoldingRangeRegistrationOptions extend= class
    TextDocumentRegistrationOptions, FoldingRangeOptions,
    StaticRegistrationOptions {
  end;

  TFoldingRangeParams extends WorkDoneProgressParams= class
    PartialResultParams {
    textDocument: TextDocumentIdentifier;
  end;

  enum FoldingRangeKind {
    Comment = 'comment',
    Imports = 'imports',
    Region = 'region'
  end;

  TFoldingRange = class
    startLine: uinteger;
    startCharacter?: uinteger;
    endLine: uinteger;
    endCharacter?: uinteger;
    kind?: string;
  end;

  TSelectionRangeClientCapabilities = class
    dynamicRegistration?: Boolean;
  end;

  TSelectionRangeOptions extends WorkDoneProgressOptions = class
  end;

  TSelectionRangeRegistrationOptions extend= class
    SelectionRangeOptions, TextDocumentRegistrationOptions,
    StaticRegistrationOptions {
  end;

  TSelectionRangeParams extends WorkDoneProgressParams= class
    PartialResultParams {
    textDocument: TextDocumentIdentifier;
    positions: Position[];
  end;

  TSelectionRange = class
    range: Range;
    parent?: SelectionRange;
  end;

  TCallHierarchyClientCapabilities = class
    dynamicRegistration?: Boolean;
  end;

  TCallHierarchyOptions extends WorkDoneProgressOptions = class
  end;

  TCallHierarchyRegistrationOptions extend= class
    TextDocumentRegistrationOptions, CallHierarchyOptions,
    StaticRegistrationOptions {
  end;

  TCallHierarchyPrepareParams extends TextDocumentPositionParams= class
    WorkDoneProgressParams {
  end;

  TCallHierarchyItem = class
    name: string;
    kind: SymbolKind;
    tags?: SymbolTag[];
    detail?: string;
    uri: DocumentUri;
    range: Range;
    selectionRange: Range;
    data?: unknown;
  end;

  TCallHierarchyIncomingCallsParams extend= class
    WorkDoneProgressParams, PartialResultParams {
    item: CallHierarchyItem;
  end;

  TCallHierarchyIncomingCall = class
    from: CallHierarchyItem;
    fromRanges: Range[];
  end;

  TCallHierarchyOutgoingCallsParams extend= class
    WorkDoneProgressParams, PartialResultParams {
    item: CallHierarchyItem;
  end;

  TCallHierarchyOutgoingCall = class
    to: CallHierarchyItem;
    fromRanges: Range[];
  end;

  enum SemanticTokenTypes {
    namespace = 'namespace',
    type = 'type',
    class'= class =
    enum = 'enum',
    T= 'interface'= class
    struct = 'struct',
    typeParameter = 'typeParameter',
    parameter = 'parameter',
    variable = 'variable',
    property = 'property',
    enumMember = 'enumMember',
    event = 'event',
    function = 'function',
    method = 'method',
    macro = 'macro',
    keyword = 'keyword',
    modifier = 'modifier',
    comment = 'comment',
    string = 'string',
    number = 'number',
    regexp = 'regexp',
    operator = 'operator'
  end;

  enum SemanticTokenModifiers {
    declaration = 'declaration',
    definition = 'definition',
    readonly = 'readonly',
    static = 'static',
    deprecated = 'deprecated',
    abstract = 'abstract',
    async = 'async',
    modification = 'modification',
    documentation = 'documentation',
    defaultLibrary = 'defaultLibrary'
  end;

  namespace TokenFormat {
    const Relative: 'relative' = 'relative';
  end;

  type TokenFormat = 'relative';

  TSemanticTokensLegend = class
    tokenTypes: string[];
    tokenModifiers: string[];
  end;

  TSemanticTokensClientCapabilities = class
    dynamicRegistration?: Boolean;
    requests: {
            range?: Boolean | {
              end;

            full?: Boolean | {
                    delta?: Boolean;
              end;
      end;

    tokenTypes: string[];
    tokenModifiers: string[];
    formats: TokenFormat[];
    overlappingTokenSupport?: Boolean;
    multilineTokenSupport?: Boolean;
  end;

  TSemanticTokensOptions extends WorkDoneProgressOptions = class
    legend: SemanticTokensLegend;
    range?: Boolean | {
      end;
    full?: Boolean | {
            delta?: Boolean;
      end;
  end;

  TSemanticTokensRegistrationOptions extend= class
    TextDocumentRegistrationOptions, SemanticTokensOptions,
    StaticRegistrationOptions {
  end;

  TSemanticTokensParams extends WorkDoneProgressParams= class
    PartialResultParams {
    textDocument: TextDocumentIdentifier;
  end;

  TSemanticTokens = class
    resultId?: string;
    data: uinteger[];
  end;

  TSemanticTokensPartialResult = class
    data: uinteger[];
  end;

  TSemanticTokensDeltaParams extends WorkDoneProgressParams= class
    PartialResultParams {
    textDocument: TextDocumentIdentifier;
    previousResultId: string;
  end;

  TSemanticTokensDelta = class
    readonly resultId?: string;
    edits: SemanticTokensEdit[];
  end;

  TSemanticTokensEdit = class
    start: uinteger;
    deleteCount: uinteger;
    data?: uinteger[];
  end;

  TSemanticTokensDeltaPartialResult = class
    edits: SemanticTokensEdit[];
  end;

  TSemanticTokensRangeParams extends WorkDoneProgressParams= class
    PartialResultParams {
    textDocument: TextDocumentIdentifier;
    range: Range;
  end;

  TSemanticTokensWorkspaceClientCapabilities = class
    refreshSupport?: Boolean;
  end;

  TLinkedEditingRangeClientCapabilities = class
    dynamicRegistration?: Boolean;
  end;

  TLinkedEditingRangeOptions extends WorkDoneProgressOptions = class
  end;

  TLinkedEditingRangeRegistrationOptions extend= class
    TextDocumentRegistrationOptions, LinkedEditingRangeOptions,
    StaticRegistrationOptions {
  end;

  TLinkedEditingRangeParams extends TextDocumentPositionParams= class
    WorkDoneProgressParams {
  end;

  TLinkedEditingRanges = class
    ranges: Range[];
    wordPattern?: string;
  end;

  TMonikerClientCapabilities = class
    dynamicRegistration?: Boolean;
  end;

  TMonikerOptions extends WorkDoneProgressOptions = class
  end;

  TMonikerRegistrationOptions extend= class
    TextDocumentRegistrationOptions, MonikerOptions {
  end;

  TMonikerParams extends TextDocumentPositionParams= class
    WorkDoneProgressParams, PartialResultParams {
  end;

  enum UniquenessLevel {
    document = 'document',
    project = 'project',
    group = 'group',
    scheme = 'scheme',
    global = 'global'
  end;

  enum MonikerKind {
    import = 'import',
    export = 'export',
    local = 'local'
  end;

  TMoniker = class
    scheme: string;
    identifier: string;
    unique: UniquenessLevel;
    kind?: MonikerKind;
  end;
*)

function MarkupKindToString(Value: TMarkupKind): String;
function StringToMarkupKind(Value: String): TMarkupKind;

implementation

function MarkupKindToString(Value: TMarkupKind): String;
begin
  case Value of
    mkPlainText:
      Result := 'plaintext';
    mkMarkDown:
      Result := 'markdown';
  end;
end;

function StringToMarkupKind(Value: String): TMarkupKind;
begin
  if Value ='plaintext' then
    Result := mkPlainText
  else
  if Value ='markdown' then
    Result := mkMarkDown
  else
    raise EJsonRpcParse.Create('Unknown markup kind');
end;


{ TCustomJsonClass }

constructor TCustomJsonClass.Create;
begin
  FJson := TJSONObject.Create;
end;

function TCustomJsonClass.GetBoolean(const Name: string): Boolean;
var
  Value: TJSONValue;
begin
  Result := False;
  Value := FJson.GetValue(Name);
  if Assigned(Value) then
    Result := Value.AsType<Boolean>;
end;

function TCustomJsonClass.GetText(const Name: string): string;
var
  Value: TJSONValue;
begin
  Result := '';
  Value := FJson.GetValue(Name);
  if Assigned(Value) then
    Result := Value.AsType<string>;
end;

function TCustomJsonClass.GetValue(const Name: string): TJSONValue;
begin
  Result := FJson.GetValue(Name);
end;

function TCustomJsonClass.RemovePair(const Str: string): TJSONPair;
begin
  Result := FJson.RemovePair(Str);
end;

function TCustomJsonClass.AddPair(const Str, Val: string): TJSONObject;
begin
  Result := FJson.AddPair(Str, Val);
end;

function TCustomJsonClass.AddPair(const Str: string;
  const Val: Integer): TJSONObject;
begin
  Result := FJson.AddPair(Str, TJSONNumber.Create(Val));
end;

function TCustomJsonClass.AddPair(const Str: string;
  const Val: Boolean): TJSONObject;
begin
  Result := FJson.AddPair(Str, TJSONBool.Create(Val));
end;

function TCustomJsonClass.AddPair(const Str: string;
  const Val: TJSONValue): TJSONObject;
begin
  Result := FJson.AddPair(Str, Val);
end;

function TCustomJsonClass.SetPair(const Str, Val: string): TJSONObject;
begin
  FJson.RemovePair(Str);
  Result := FJson.AddPair(Str, Val);
end;

function TCustomJsonClass.SetPair(const Str: string;
  const Val: TJSONValue): TJSONObject;
begin
  FJson.RemovePair(Str);
  Result := FJson.AddPair(Str, Val);
end;

function TCustomJsonClass.SetPair(const Str: string;
  const Val: Integer): TJSONObject;
begin
  FJson.RemovePair(Str);
  Result := FJson.AddPair(Str, TJSONNumber.Create(Val));
end;

function TCustomJsonClass.SetPair(const Str: string;
  const Val: Boolean): TJSONObject;
begin
  FJson.RemovePair(Str);
  Result := FJson.AddPair(Str, TJSONBool.Create(Val));
end;

constructor TCustomJsonClass.Create(Json: TJSONObject);
begin
  FJson := Json;
end;


{ TMessage }

constructor TMessage.Create;
begin
  inherited;
  AddPair('jsonrpc', '2.0');
end;

constructor TMessage.Create(Json: TJSONObject);
begin
  inherited Create(Json);

  if GetText('jsonrpc') <> '2.0' then
    raise EJsonRpcParse.Create('Invalid JSON RPC version');
end;


{ TMessageRequest }

constructor TMessageRequest.Create(Json: TJSONObject);
begin
  inherited Create;

  Assert(GetText('method') = GetMethod);
end;

constructor TMessageRequest.Create;
begin
  inherited Create;

  AddPair('method', GetMethod);
end;

constructor TMessageRequest.Create(ID: Integer);
begin
  Create;

  AddPair('id', TJSONNumber.Create(ID));
end;

constructor TMessageRequest.Create(ID: String);
begin
  Create;

  AddPair('id', ID);
end;


{ TMessageResponse }

constructor TMessageResponse.Create;
begin
  inherited Create;
end;

constructor TMessageResponse.Create(ID: Integer);
begin
  Create;

  AddPair('id', TJSONNumber.Create(ID));
end;

constructor TMessageResponse.Create(ID: String);
begin
  Create;

  AddPair('id', ID);
end;

function TMessageResponse.GetID: TJSONValue;
begin
  Result := GetValue('id');
end;

function TMessageResponse.GetResult: TJSONValue;
begin
  Result := GetValue('result');
end;

procedure TMessageResponse.SetID(const Value: TJSONValue);
begin
  SetPair('id', Value);
end;

procedure TMessageResponse.SetResult(const Value: TJSONValue);
begin
  RemovePair('result');
  if Assigned(Value) then
    AddPair('result', Value)
end;


{ TMessageResponse }

constructor TMessageResponse.Create(Json: TJSONObject);
begin
  inherited Create(Json);

  if GetValue('error') is TJSONObject then
    FError := TResponseError.Create(TJSONObject(GetValue('error')));
end;


{ TMessageResponse.TResponseError }

constructor TMessageResponse.TResponseError.Create(Json: TJSONObject);
begin
  inherited Create(Json);
  FData := GetValue('data');
end;

function TMessageResponse.TResponseError.GetCode: TErrorCodes;
begin
  Result := GetValue('code').AsType<TErrorCodes>;
end;

function TMessageResponse.TResponseError.GetMessage: string;
begin
  Result := GetText('message');
end;

procedure TMessageResponse.TResponseError.SetData(const Value: TJSONValue);
begin
  RemovePair('data');
  if Assigned(Value) then
    AddPair('data', Value)
end;


{ TMessageNotification }

constructor TMessageNotification.Create;
begin
  inherited Create;

  AddPair('method', GetMethod);
end;

constructor TMessageNotification.Create(Json: TJSONObject);
begin
  inherited Create(Json);

  Assert(GetText('method') = GetMethod);
end;


{ TCancellationMessage }

constructor TCancellationNotification.Create;
begin
  inherited Create;

  FParams := TCancelParams.Create;
  AddPair('params', FParams.Json);
end;

constructor TCancellationNotification.Create(Json: TJSONObject);
begin
  inherited Create(Json);

  FParams := TCancelParams.Create(TJSONObject(GetValue('params')));
end;

class function TCancellationNotification.GetMethod: String;
begin
  Result := 'cancelRequest';
end;


{ TCancellationNotification.TCancelParams }

constructor TCancellationNotification.TCancelParams.Create;
begin
  inherited;

  Id := TJSONString.Create;
end;

constructor TCancellationNotification.TCancelParams.Create(Json: TJSONObject);
begin
  inherited;

  // check format
  if not ((GetValue('id') is TJSONString) or
          (GetValue('id') is TJSONNumber)) then
    raise EJsonRpcParse.Create('id must be either a string or a number');
end;

function TCancellationNotification.TCancelParams.GetID: TJSONValue;
begin
  Result := GetValue('id');
end;

procedure TCancellationNotification.TCancelParams.SetID(const Value: TJSONValue);
begin
  SetPair('id', Value);
end;


{ TProgressNotification }

constructor TProgressNotification.Create;
begin
  inherited Create;

  FParams := TProgressParams.Create;
  AddPair('params', FParams.Json);
end;

constructor TProgressNotification.Create(Json: TJSONObject);
begin
  inherited Create(Json);

  FParams := TProgressParams.Create(TJSONObject(GetValue('params')));
end;

class function TProgressNotification.GetMethod: String;
begin
  Result := 'progress';
end;


{ TProgressNotification.TProgressParams }

constructor TProgressNotification.TProgressParams.Create;
begin
  inherited;

  Token := TJSONString.Create;
  Value := TJSONString.Create;
end;

constructor TProgressNotification.TProgressParams.Create(Json: TJSONObject);
begin
  inherited;

  // check format
  if not ((FJson.GetValue('token') is TJSONString) or
          (FJson.GetValue('token') is TJSONNumber)) then
    raise EJsonRpcParse.Create('token must be either a string or a number');
end;

function TProgressNotification.TProgressParams.GetToken: TJSONValue;
begin
  Result := FJson.GetValue('token');
end;

function TProgressNotification.TProgressParams.GetValue: TJSONValue;
begin
  Result := FJson.GetValue('value');
end;

procedure TProgressNotification.TProgressParams.SetToken(
  const Value: TJSONValue);
begin
  SetPair('token', Value);
end;

procedure TProgressNotification.TProgressParams.SetValue(
  const Value: TJSONValue);
begin
  SetPair('value', Value);
end;


{ TRegularExpressionsClientCapabilities }

function TRegularExpressionsClientCapabilities.GetEngine: string;
begin
  Result := GetText('token');
end;

function TRegularExpressionsClientCapabilities.GetVersion: TJSONString;
begin
  Result := GetValue('version') as TJSONString;
end;


{ TPosition }

constructor TPosition.Create;
begin
  inherited;

  Character := 0;
  Line := 0;
end;

function TPosition.GetCharacter: Cardinal;
begin
  Result := GetValue('character').AsType<Cardinal>;
end;

function TPosition.GetLine: Cardinal;
begin
  Result := GetValue('line').AsType<Cardinal>;
end;

procedure TPosition.SetCharacter(const Value: Cardinal);
begin
  SetPair('character', TJSONNumber.Create(Value));
end;

procedure TPosition.SetLine(const Value: Cardinal);
begin
  SetPair('line', TJSONNumber.Create(Value));
end;


{ TRange }

constructor TRange.Create;
begin
  inherited;

  FStart := TPosition.Create;
  FEnd := TPosition.Create;
  AddPair('start', FStart.Json as TJSONObject);
  AddPair('end', FEnd.Json as TJSONObject);
end;

constructor TRange.Create(Json: TJSONObject);
begin
  inherited Create(Json);

  FStart := TPosition.Create(GetValue('start') as TJSONObject);
  FEnd := TPosition.Create(GetValue('end') as TJSONObject);
end;


{ TLocation }

constructor TLocation.Create;
begin
  inherited;

  Uri := '';
  FRange := TRange.Create;
  AddPair('range', FRange.Json as TJSONObject);
end;

constructor TLocation.Create(Json: TJSONObject);
begin
  inherited Create(Json);

  FUri := GetText('uri');
  FRange := TRange.Create(GetValue('range') as TJSONObject);
end;

procedure TLocation.SetUri(const Value: TDocumentUri);
begin
  SetPair('uri', TJSONString.Create(Value));
end;


{ TLocationLink }

constructor TLocationLink.Create;
begin
  inherited;

  TargetUri := '';
  FTargetRange := TRange.Create;
  FTargetSelectionRange := TRange.Create;
end;

constructor TLocationLink.Create(Json: TJSONObject);
begin
  inherited Create(Json);

  FOriginSelectionRange := TRange.Create(GetValue('originSelectionRange') as TJSONObject);
  FTargetUri := GetText('targetUri');
  FTargetRange := TRange.Create(GetValue('targetRange') as TJSONObject);
  FTargetSelectionRange := TRange.Create(GetValue('targetSelectionRange') as TJSONObject);
end;

procedure TLocationLink.SetTargetUri(const Value: TDocumentUri);
begin
  SetPair('uri', TJSONString.Create(Value));
end;

procedure TLocationLink.SetOriginSelectionRange(const Value: TRange);
begin
  if FOriginSelectionRange <> Value then
  begin
    FOriginSelectionRange := Value;
    RemovePair('originSelectionRange');
    if Assigned(Value) then
      AddPair('originSelectionRange', FOriginSelectionRange.Json);
  end;
end;


{ TDiagnostics }

constructor TDiagnostics.Create;
begin
  inherited;

  FRange := TRange.Create;
  AddPair('range', FRange.Json);

  Message := '';
end;

constructor TDiagnostics.Create(Json: TJSONObject);
begin
  inherited Create(Json);

  FRange := TRange.Create(GetValue('range') as TJSONObject);
end;

function TDiagnostics.GetMessage: String;
begin
  Result := GetText('message');
end;

procedure TDiagnostics.SetMessage(const Value: String);
begin
  SetPair('message', TJSONString.Create(Value));
end;


{ TCommand }

constructor TCommand.Create;
begin
  inherited;

  Title := '';
  Command := '';
end;

constructor TCommand.Create(Json: TJSONObject);
begin
  inherited Create(Json);
end;

function TCommand.GetCommand: String;
begin
  Result := GetText('command');
end;

function TCommand.GetTitle: String;
begin
  Result := GetText('title');
end;

procedure TCommand.SetCommand(const Value: String);
begin
  SetPair('command', Value);
end;

procedure TCommand.SetTitle(const Value: String);
begin
  SetPair('title', Value);
end;


{ TTextEdit }

constructor TTextEdit.Create;
begin
  inherited Create;

  FRange := TRange.Create;
  AddPair('range', FRange.Json);

  NewText := '';
end;

constructor TTextEdit.Create(Json: TJSONObject);
begin
  inherited Create(Json);

  FRange := TRange.Create(GetValue('range') as TJSONObject);
end;

function TTextEdit.GetNewText: String;
begin
  Result := GetText('newText');
end;

procedure TTextEdit.SetNewText(const Value: String);
begin
  SetPair('newText', Value);
end;


{ TMarkupContent }

constructor TMarkupContent.Create;
begin
  inherited Create;
end;

constructor TMarkupContent.Create(Json: TJSONObject);
begin
  inherited Create(Json);
end;

function TMarkupContent.GetKind: TMarkupKind;
begin
  Result := StringToMarkupKind(GetText('kind'));
end;

function TMarkupContent.GetValue: String;
begin
  Result := GetText('value');
end;

procedure TMarkupContent.SetKind(const Value: TMarkupKind);
begin
  SetPair('kind', MarkupKindToString(Value));
end;

procedure TMarkupContent.SetValue(const Value: String);
begin
  SetPair('value', Value);
end;


{ TWorkDoneProgress }

function TWorkDoneProgress.GetMessage: string;
begin
  Result := GetText('message');
end;

procedure TWorkDoneProgress.SetMessage(const Value: string);
begin
  RemovePair('message');
  if Value <> '' then
    AddPair('message', Value);
end;


{ TWorkDoneProgressParams }

function TWorkDoneProgressParams.GetWorkDoneToken: TJSONValue;
begin
  Result := GetValue('workDoneToken');
end;

procedure TWorkDoneProgressParams.SetWorkDoneToken(const Value: TJSONValue);
begin
  SetPair('workDoneToken', Value);
end;


{ TWorkDoneProgressBegin }

constructor TWorkDoneProgressBegin.Create;
begin
  inherited;

  Title := '';
end;

class function TWorkDoneProgressBegin.GetKind: String;
begin
  Result := 'begin';
end;

function TWorkDoneProgressBegin.GetCancellable: Boolean;
begin
  Result := GetValue('cancellable').AsType<boolean>;
end;

function TWorkDoneProgressBegin.GetPercentage: Cardinal;
begin
  Result := GetValue('percentage').AsType<Cardinal>;
end;

function TWorkDoneProgressBegin.GetTitle: string;
begin
  Result := GetText('title');
end;

procedure TWorkDoneProgressBegin.SetCancellable(const Value: Boolean);
begin
  SetPair('cancellable', TJSONBool.Create(Value));
end;

procedure TWorkDoneProgressBegin.SetPercentage(const Value: Cardinal);
begin
  SetPair('percentage', TJSONNumber.Create(Value));
end;

procedure TWorkDoneProgressBegin.SetTitle(const Value: string);
begin
  SetPair('title', Value);
end;


{ TWorkDoneProgressReport }

class function TWorkDoneProgressReport.GetKind: String;
begin
  Result := 'report';
end;

{ TWorkDoneProgressEnd }

class function TWorkDoneProgressEnd.GetKind: String;
begin
  Result := 'end';
end;


{ TInitializeParams.TClientInfo }

function TMessageRequestInitialize.TInitializeParams.TClientInfo.GetName: string;
begin
  Result := GetText('name');
end;

function TMessageRequestInitialize.TInitializeParams.TClientInfo.GetVersion: string;
begin
  Result := GetText('version');
end;

procedure TMessageRequestInitialize.TInitializeParams.TClientInfo.SetName(const Value: string);
begin
  SetPair('name', Value);
end;

procedure TMessageRequestInitialize.TInitializeParams.TClientInfo.SetVersion(const Value: string);
begin
  RemovePair('version');
  if Value <> '' then
    AddPair('version', Value);
end;


{ TMessageRequestInitialize.TInitializeParams }

constructor TMessageRequestInitialize.TInitializeParams.Create;
begin
  inherited Create;

  AddPair('processId', TJSONNull.Create);
  AddPair('rootUri', TJSONNull.Create);
end;

constructor TMessageRequestInitialize.TInitializeParams.Create(Json: TJSONObject);
begin
  inherited Create(Json);
end;

function TMessageRequestInitialize.TInitializeParams.GetInitializationOptions: TJsonValue;
begin
  Result := GetValue('initializationOptions');
end;

function TMessageRequestInitialize.TInitializeParams.GetLocale: TJSONString;
begin
  Result := GetValue('locale') as TJSONString;
end;

function TMessageRequestInitialize.TInitializeParams.GetProcessId: TJSONValue;
begin
  Result := GetValue('processId');
end;

function TMessageRequestInitialize.TInitializeParams.GetRootPath: TJSONString;
begin
  Result := GetValue('rootPath') as TJSONString;
end;

function TMessageRequestInitialize.TInitializeParams.GetRootUri: TDocumentUri;
begin
  Result := GetText('rootUri');
end;

function TMessageRequestInitialize.TInitializeParams.GetTraceValue: TTraceValue;
var
  Value: String;
begin
  if Assigned(GetValue('trace')) then
    Result := tvOff
  else
  begin
    Value := Json.GetValue('trace').AsType<String>;
    if Value = 'off' then
      Result := tvOff
    else
    if Value = 'messages' then
      Result := tvMessages
    else
    if Value = 'verbose' then
      Result := tvVerbose
    else
      raise EJsonRpcParse.Create('Unknown trace value');
  end;
end;

procedure TMessageRequestInitialize.TInitializeParams.SetInitializationOptions(const Value: TJsonValue);
begin
  RemovePair('initializationOptions');
  if Assigned(Value) then
    AddPair('initializationOptions', Value);
end;

procedure TMessageRequestInitialize.TInitializeParams.SetLocale(const Value: TJSONString);
begin
  RemovePair('locale');
  if Assigned(Value) then
    AddPair('locale', Value);
end;

procedure TMessageRequestInitialize.TInitializeParams.SetProcessId(const Value: TJSONValue);
begin
  RemovePair('processId');
  if Assigned(Value) then
    AddPair('processId', Value);
end;

procedure TMessageRequestInitialize.TInitializeParams.SetRootPath(const Value: TJSONString);
begin
  RemovePair('rootPath');
  if Assigned(Value) then
  begin
    RemovePair('rootUri');
    AddPair('rootPath', Value);
  end;
end;

procedure TMessageRequestInitialize.TInitializeParams.SetRootUri(const Value: TDocumentUri);
begin
  SetPair('rootUri', Value)
end;

procedure TMessageRequestInitialize.TInitializeParams.SetTraceValue(const Value: TTraceValue);
begin
  case Value of
     tvOff:
       Json.AddPair('trace', 'off');
     tvMessages:
       Json.AddPair('trace', 'messages');
     tvVerbose:
       Json.AddPair('trace', 'verbose');
  end;
end;


{ TMessageRequestInitialize }

constructor TMessageRequestInitialize.Create;
begin
  inherited Create;

  FParams := TInitializeParams.Create;
  AddPair('params', FParams.Json);
end;

constructor TMessageRequestInitialize.Create(Json: TJSONObject);
begin
  inherited Create(Json);

  FParams := TInitializeParams.Create(TJSONObject(GetValue('params')));
end;

class function TMessageRequestInitialize.GetMethod: String;
begin
  Result := 'initialize';
end;


{ TClientCapabilities.TWorkspace.TFileOperations }

function TClientCapabilities.TWorkspace.TFileOperations.GetDidCreate: Boolean;
begin
  Result := GetBoolean('didCreate');
end;

function TClientCapabilities.TWorkspace.TFileOperations.GetDidDelete: Boolean;
begin
  Result := GetBoolean('didDelete');
end;

function TClientCapabilities.TWorkspace.TFileOperations.GetDidRename: Boolean;
begin
  Result := GetBoolean('didRename');
end;

function TClientCapabilities.TWorkspace.TFileOperations.GetDynamicRegistration: Boolean;
begin
  Result := GetBoolean('dynamicRegistration');
end;

function TClientCapabilities.TWorkspace.TFileOperations.GetWillCreate: Boolean;
begin
  Result := GetBoolean('willCreate');
end;

function TClientCapabilities.TWorkspace.TFileOperations.GetWillDelete: Boolean;
begin
  Result := GetBoolean('willCreate');
end;

function TClientCapabilities.TWorkspace.TFileOperations.GetWillRename: Boolean;
begin
  Result := GetBoolean('willCreate');
end;

procedure TClientCapabilities.TWorkspace.TFileOperations.SetDidCreate(
  const Value: Boolean);
begin
  SetPair('didCreate', Value);
end;

procedure TClientCapabilities.TWorkspace.TFileOperations.SetDidDelete(
  const Value: Boolean);
begin
  SetPair('didDelete', Value);
end;

procedure TClientCapabilities.TWorkspace.TFileOperations.SetDidRename(
  const Value: Boolean);
begin
  SetPair('didRename', Value);
end;

procedure TClientCapabilities.TWorkspace.TFileOperations.SetDynamicRegistration(
  const Value: Boolean);
begin
  SetPair('didDynamicRegistration', Value);
end;

procedure TClientCapabilities.TWorkspace.TFileOperations.SetWillCreate(
  const Value: Boolean);
begin
  SetPair('didWillCreate', Value);
end;

procedure TClientCapabilities.TWorkspace.TFileOperations.SetWillDelete(
  const Value: Boolean);
begin
  SetPair('didWillDelete', Value);
end;

procedure TClientCapabilities.TWorkspace.TFileOperations.SetWillRename(
  const Value: Boolean);
begin
  SetPair('didWillRename', Value);
end;


{ TClientCapabilities.TWorkspace }

function TClientCapabilities.TWorkspace.GetApplyEdit: Boolean;
begin
  Result := GetBoolean('applyEdit');
end;

procedure TClientCapabilities.TWorkspace.SetApplyEdit(
  const Value: Boolean);
begin
  RemovePair('applyEdit');
  if Value then
    AddPair('applyEdit', Value);
end;

procedure TClientCapabilities.TWorkspace.SetFileOperations(
  const Value: TFileOperations);
begin
  RemovePair('fileOperations');
  FFileOperations := Value;
  if Assigned(FFileOperations) then
    AddPair('fileOperations', FFileOperations.Json);
end;


{ TClientCapabilities }

function TClientCapabilities.GetExperimental: TJSONValue;
begin
  Result := GetValue('experimental');
end;

procedure TClientCapabilities.SetExperimental(const Value: TJSONValue);
begin
  RemovePair('experimental');
  if Assigned(Value) then
    AddPair('experimental', Value);
end;

procedure TClientCapabilities.SetWorkspace(
  const Value: TWorkspace);
begin
  RemovePair('workspace');
  FWorkspace := Value;
  if Assigned(FWorkspace) then
    AddPair('workspace', FWorkspace.Json);
end;


{ TInitializeResult }

constructor TInitializeResult.Create;
begin
  inherited Create;
  FCapabilities := TServerCapabilities.Create;
end;

constructor TInitializeResult.Create(Json: TJSONObject);
begin
  inherited Create(Json);
  FCapabilities := TServerCapabilities.Create(Json.GetValue('capabilities') as TJSONObject);
end;

procedure TInitializeResult.SetServerInfo(const Value: TServerInfo);
begin
  RemovePair('serverInfo');
  FServerInfo := Value;
  if Assigned(Value) then
    AddPair('serverInfo', FServerInfo.Json);
end;


{ TInitializeResult.TServerInfo }

function TInitializeResult.TServerInfo.GetName: string;
begin
  Result := GetText('name');
end;

function TInitializeResult.TServerInfo.GetVersion: string;
begin
  Result := GetText('version');
end;

procedure TInitializeResult.TServerInfo.SetName(const Value: string);
begin
  SetPair('name', Value);
end;

procedure TInitializeResult.TServerInfo.SetVersion(const Value: string);
begin
  RemovePair('version');
  if Value <> '' then
    AddPair('version', Value);
end;


{ TServerCapabilities }

function TServerCapabilities.GetExperimental: TJSONValue;
begin
  Result := GetValue('experimental');
end;

procedure TServerCapabilities.SetExperimental(const Value: TJSONValue);
begin
  RemovePair('experimental');
  if Assigned(Value) then
    AddPair('experimental', Value);
end;


{ TMessageNotificationInitialized }

constructor TMessageNotificationInitialized.Create;
begin
  inherited Create;

  AddPair('params', TJSONObject.Create);
end;

class function TMessageNotificationInitialized.GetMethod: String;
begin
  Result := 'initialized';
end;


{ TMessageRequestShutdown }

constructor TMessageRequestShutdown.Create;
begin
  inherited;

  AddPair('params', TJSONObject.Create);
end;

class function TMessageRequestShutdown.GetMethod: String;
begin
  Result := 'shutdown';
end;


{ TMessageNotificationExit }

constructor TMessageNotificationExit.Create;
begin
  inherited;

  AddPair('params', TJSONObject.Create);
end;

class function TMessageNotificationExit.GetMethod: String;
begin
  Result := 'exit';
end;


{ TMessageNotificationLogTrace.TLogTraceParams }

constructor TMessageNotificationLogTrace.TLogTraceParams.Create;
begin
  inherited Create;
end;

constructor TMessageNotificationLogTrace.TLogTraceParams.Create(
  Json: TJSONObject);
begin
  inherited Create(Json);
end;

function TMessageNotificationLogTrace.TLogTraceParams.GetMessage: string;
begin
  Result := GetText('message');
end;

function TMessageNotificationLogTrace.TLogTraceParams.GetVerbose: TJSONString;
begin
  Result := GetValue('verbose') as TJSONString;
end;

procedure TMessageNotificationLogTrace.TLogTraceParams.SetMessage(
  const Value: string);
begin
  SetPair('message', Value);
end;

procedure TMessageNotificationLogTrace.TLogTraceParams.SetVerbose(
  const Value: TJSONString);
begin
  RemovePair('verbose');
  if Assigned(Value) then
    AddPair('verbose', Value);
end;


{ TMessageNotificationLogTrace }

constructor TMessageNotificationLogTrace.Create;
begin
  inherited Create;

  FParams := TLogTraceParams.Create;
  AddPair('params', FParams.Json);
end;

constructor TMessageNotificationLogTrace.Create(Json: TJSONObject);
begin
  inherited Create(Json);

  FParams := TLogTraceParams.Create(TJSONObject(GetValue('params')));
end;

class function TMessageNotificationLogTrace.GetMethod: String;
begin
  Result := '$/logTrace';
end;


{ TMessageNotificationSetTrace.TSetTraceParams }

constructor TMessageNotificationSetTrace.TSetTraceParams.Create;
begin
  inherited Create;
end;

constructor TMessageNotificationSetTrace.TSetTraceParams.Create(
  Json: TJSONObject);
begin
  inherited Create(Json);
end;

function TMessageNotificationSetTrace.TSetTraceParams.GetValue: string;
begin
  Result := GetText('value');
end;

procedure TMessageNotificationSetTrace.TSetTraceParams.SetValue(
  const Value: string);
begin
  SetPair('value', Value)
end;


{ TMessageNotificationSetTrace }

constructor TMessageNotificationSetTrace.Create;
begin
  inherited Create;

  FParams := TSetTraceParams.Create;
  AddPair('params', FParams.Json);
end;

constructor TMessageNotificationSetTrace.Create(Json: TJSONObject);
begin
  inherited Create(Json);

  FParams := TSetTraceParams.Create(TJSONObject(GetValue('params')));
end;

class function TMessageNotificationSetTrace.GetMethod: String;
begin
  Result := '$/setTrace';
end;

end.
