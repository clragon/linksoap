#ifndef CLIPBOARD_MANAGER_PLUGIN_H_
#define CLIPBOARD_MANAGER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#ifdef CLIPBOARD_MANAGER_PLUGIN_IMPL
#define CLIPBOARD_MANAGER_EXPORT __declspec(dllexport)
#else
#define CLIPBOARD_MANAGER_EXPORT __declspec(dllimport)
#endif

class CLIPBOARD_MANAGER_EXPORT ClipboardManagerPlugin : public flutter::Plugin
{
public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

    ClipboardManagerPlugin();
    virtual ~ClipboardManagerPlugin();

private:
    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

extern "C" CLIPBOARD_MANAGER_EXPORT void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

#endif // CLIPBOARD_MANAGER_PLUGIN_H_
