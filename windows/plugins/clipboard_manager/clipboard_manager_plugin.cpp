#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>
#include <string>
#include <memory>
#include <utility>

#include "clipboard_manager_plugin.h"

namespace
{
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel;

  std::string GetClipboardText()
  {
    if (!OpenClipboard(nullptr))
    {
      return "";
    }

    HANDLE hData = GetClipboardData(CF_TEXT);
    if (hData == nullptr)
    {
      CloseClipboard();
      return "";
    }

    char *pszText = static_cast<char *>(GlobalLock(hData));
    if (pszText == nullptr)
    {
      CloseClipboard();
      return "";
    }

    std::string text(pszText);
    GlobalUnlock(hData);
    CloseClipboard();
    return text;
  }

  void SetClipboardText(const std::string &text)
  {
    if (!OpenClipboard(nullptr))
    {
      return;
    }

    EmptyClipboard();
    HGLOBAL hClipboardData = GlobalAlloc(GMEM_DDESHARE, text.size() + 1);

    if (!hClipboardData)
    {
      CloseClipboard();
      return;
    }

    char *pClipboardData = static_cast<char *>(GlobalLock(hClipboardData));

    if (!pClipboardData)
    {
      GlobalFree(hClipboardData);
      CloseClipboard();
      return;
    }

    strcpy_s(pClipboardData, text.size() + 1, text.c_str());
    GlobalUnlock(hClipboardData);
    SetClipboardData(CF_TEXT, hClipboardData);
    CloseClipboard();
  }

  void ClipboardListener()
  {
    std::string clipboard_content = GetClipboardText();
    auto args = std::make_unique<flutter::EncodableValue>(clipboard_content);
    channel->InvokeMethod("processText", std::move(args), nullptr);
  }

  void SetupNativeChannel(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    ClipboardListener();
    result->Success(flutter::EncodableValue(true));
  }
}

void ClipboardManagerPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar)
{
  channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      registrar->messenger(), "net.clynamic.linksoap/laundromat",
      &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<ClipboardManagerPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result)
      {
        if (call.method_name().compare("setupNativeChannel") == 0)
        {
          SetupNativeChannel(call, std::move(result));
        }
        else
        {
          result->NotImplemented();
        }
      });

  registrar->AddPlugin(std::move(plugin));
}

ClipboardManagerPlugin::ClipboardManagerPlugin() {}

ClipboardManagerPlugin::~ClipboardManagerPlugin() {}

extern "C" __declspec(dllexport) void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar)
{
  ClipboardManagerPlugin::RegisterWithRegistrar(registrar);
}
