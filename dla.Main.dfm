object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'Explore the DelphiLSP language server protocol'
  ClientHeight = 409
  ClientWidth = 688
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 229
    Width = 688
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitTop = 0
    ExplicitWidth = 560
  end
  object Splitter2: TSplitter
    Left = 0
    Top = 69
    Width = 688
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitLeft = 8
    ExplicitTop = 63
  end
  object GroupBoxOutput: TGroupBox
    AlignWithMargins = True
    Left = 4
    Top = 236
    Width = 680
    Height = 169
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    Caption = 'Output'
    TabOrder = 0
    object MemoOutput: TMemo
      AlignWithMargins = True
      Left = 6
      Top = 19
      Width = 668
      Height = 144
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      ReadOnly = True
      TabOrder = 0
    end
  end
  object GroupBoxInput: TGroupBox
    AlignWithMargins = True
    Left = 4
    Top = 76
    Width = 680
    Height = 149
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alTop
    Caption = 'Input'
    TabOrder = 1
    object MemoInput: TMemo
      AlignWithMargins = True
      Left = 6
      Top = 19
      Width = 577
      Height = 124
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      TabOrder = 0
    end
    object Panel1: TPanel
      Left = 587
      Top = 15
      Width = 91
      Height = 132
      Align = alRight
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 1
      DesignSize = (
        91
        132)
      object ButtonSend: TButton
        AlignWithMargins = True
        Left = 3
        Top = 4
        Width = 80
        Height = 25
        Caption = '&Send'
        TabOrder = 0
        OnClick = ButtonSendClick
      end
      object ButtonClear: TButton
        AlignWithMargins = True
        Left = 3
        Top = 103
        Width = 80
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = '&Clear'
        TabOrder = 1
        OnClick = ButtonClearClick
      end
    end
  end
  object GroupBoxPredefined: TGroupBox
    AlignWithMargins = True
    Left = 4
    Top = 4
    Width = 680
    Height = 61
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alTop
    Caption = 'Predefined JSON RPC calls'
    TabOrder = 2
    object ButtonInitialize: TButton
      Left = 16
      Top = 24
      Width = 75
      Height = 25
      Caption = '&Initialize'
      TabOrder = 0
      OnClick = ButtonInitializeClick
    end
    object ButtonInitialized: TButton
      Left = 97
      Top = 24
      Width = 75
      Height = 25
      Caption = '&Initialized'
      TabOrder = 1
      OnClick = ButtonInitializedClick
    end
    object ButtonShutdown: TButton
      Left = 178
      Top = 24
      Width = 75
      Height = 25
      Caption = '&Shutdown'
      TabOrder = 2
      OnClick = ButtonShutdownClick
    end
    object ButtonExit: TButton
      Left = 259
      Top = 24
      Width = 75
      Height = 25
      Caption = '&Exit'
      TabOrder = 3
      OnClick = ButtonExitClick
    end
  end
end
