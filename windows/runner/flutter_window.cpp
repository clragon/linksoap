#include "flutter_window.h"

#include <optional>
#include <windows.h>
#include <memory>
#include <string>

#include "flutter/generated_plugin_registrant.h"
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <flutter/method_result_functions.h>

FlutterWindow::FlutterWindow(const flutter::DartProject &project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate()
{
  if (!Win32Window::OnCreate())
  {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view())
  {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  clipboard_channel_ = std::make_unique<flutter::MethodChannel<>>(
      flutter_controller_->engine()->messenger(), "clipboard_manager",
      &flutter::StandardMethodCodec::GetInstance());

  clipboard_channel_->SetMethodCallHandler(
      [](const flutter::MethodCall<>& call,
         std::unique_ptr<flutter::MethodResult<>> result) {
        if (call.method_name() == "initClipboardListener") {
          result->Success(flutter::EncodableValue(true));
        } else {
          result->NotImplemented();
        }
      });

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  AddClipboardFormatListener(GetHandle());

  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy()
{
  if (flutter_controller_)
  {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept
{
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_)
  {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result)
    {
      return *result;
    }
  }

  switch (message)
  {
  case WM_FONTCHANGE:
    flutter_controller_->engine()->ReloadSystemFonts();
    break;
  case WM_CLIPBOARDUPDATE:
    if (ignoring_clipboard_update_) {
      ignoring_clipboard_update_ = false;
      break;
    }
    if (clipboard_channel_ && OpenClipboard(hwnd)) {
      HANDLE hData = GetClipboardData(CF_UNICODETEXT);
      if (hData != nullptr) {
        wchar_t* pszText = static_cast<wchar_t*>(GlobalLock(hData));
        if (pszText != nullptr) {
          int size_needed = WideCharToMultiByte(CP_UTF8, 0, pszText, -1, nullptr, 0, nullptr, nullptr);
          std::string text(size_needed - 1, 0);
          WideCharToMultiByte(CP_UTF8, 0, pszText, -1, &text[0], size_needed, nullptr, nullptr);
          GlobalUnlock(hData);
          CloseClipboard();

          auto args = std::make_unique<flutter::EncodableValue>(text);
          clipboard_channel_->InvokeMethod("onClipboardChanged", std::move(args),
            std::make_unique<flutter::MethodResultFunctions<>>(
              [this, hwnd, text](const flutter::EncodableValue* success_value) {
                if (success_value && std::holds_alternative<std::string>(*success_value)) {
                  std::string transformed = std::get<std::string>(*success_value);
                  if (transformed != text && OpenClipboard(hwnd)) {
                    ignoring_clipboard_update_ = true;
                    EmptyClipboard();
                    int size_needed = MultiByteToWideChar(CP_UTF8, 0, transformed.c_str(), -1, nullptr, 0);
                    HGLOBAL hClipboardData = GlobalAlloc(GMEM_MOVEABLE, size_needed * sizeof(wchar_t));
                    if (hClipboardData) {
                      wchar_t* pClipboardData = static_cast<wchar_t*>(GlobalLock(hClipboardData));
                      if (pClipboardData) {
                        MultiByteToWideChar(CP_UTF8, 0, transformed.c_str(), -1, pClipboardData, size_needed);
                        GlobalUnlock(hClipboardData);
                        SetClipboardData(CF_UNICODETEXT, hClipboardData);
                      }
                    }
                    CloseClipboard();
                  }
                }
              },
              nullptr, nullptr));
          return 0;
        }
      }
      CloseClipboard();
    }
    break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
