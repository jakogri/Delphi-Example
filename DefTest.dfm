object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 321
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object Edit1: TEdit
    Left = 24
    Top = 48
    Width = 457
    Height = 21
    TabOrder = 0
    OnChange = Edit1Change
  end
  object StaticText1: TStaticText
    Left = 24
    Top = 25
    Width = 98
    Height = 17
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1092#1086#1088#1084#1091#1083#1091':'
    TabOrder = 1
  end
  object Button1: TButton
    Left = 24
    Top = 75
    Width = 121
    Height = 25
    Caption = #1056#1072#1089#1095#1080#1090#1072#1090#1100' '#1079#1085#1072#1095#1077#1085#1080#1077
    TabOrder = 2
    OnClick = Button1Click
  end
  object StaticText2: TStaticText
    Left = 24
    Top = 123
    Width = 61
    Height = 17
    Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090':'
    TabOrder = 3
  end
  object ResultText: TRichEdit
    Left = 24
    Top = 146
    Width = 185
    Height = 21
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Lines.Strings = (
      '')
    ParentFont = False
    ReadOnly = True
    TabOrder = 4
    Zoom = 100
  end
end
