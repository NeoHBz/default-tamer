//
//  DefaultBrowserSettingsView.swift
//  Default Tamer
//
//  Shared component for Fallback and Priority browser configuration
//

import SwiftUI

struct DefaultBrowserSettingsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Prioritize Open/Running Browsers", isOn: Binding(
                get: { appState.settings.prioritizeOpenBrowsers },
                set: { newValue in
                    appState.settings.prioritizeOpenBrowsers = newValue
                    appState.updateSettings(appState.settings)
                }
            ))
            
            if appState.settings.prioritizeOpenBrowsers {
                VStack(alignment: .leading, spacing: 8) {
                    Text("The first open browser in this list will be used:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    List {
                        ForEach(appState.settings.priorityBrowserIds, id: \.self) { browserId in
                            if let browser = appState.browserManager.getBrowser(byId: browserId) {
                                HStack {
                                    if let icon = browser.getIcon() {
                                        Image(nsImage: icon)
                                            .resizable()
                                            .frame(width: 16, height: 16)
                                    }
                                    Text(browser.displayName)
                                    Spacer()
                                    
                                    HStack(spacing: 4) {
                                        Button(action: {
                                            if let index = appState.settings.priorityBrowserIds.firstIndex(of: browserId), index > 0 {
                                                appState.settings.priorityBrowserIds.swapAt(index, index - 1)
                                                appState.updateSettings(appState.settings)
                                            }
                                        }) {
                                            Image(systemName: "chevron.up")
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(appState.settings.priorityBrowserIds.first == browserId)
                                        
                                        Button(action: {
                                            if let index = appState.settings.priorityBrowserIds.firstIndex(of: browserId), index < appState.settings.priorityBrowserIds.count - 1 {
                                                appState.settings.priorityBrowserIds.swapAt(index, index + 1)
                                                appState.updateSettings(appState.settings)
                                            }
                                        }) {
                                            Image(systemName: "chevron.down")
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(appState.settings.priorityBrowserIds.last == browserId)
                                        
                                        Button(action: {
                                            appState.settings.priorityBrowserIds.removeAll(where: { $0 == browserId })
                                            appState.updateSettings(appState.settings)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.secondary)
                                        }
                                        .buttonStyle(.plain)
                                        .padding(.leading, 8)
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .onMove { source, destination in
                            appState.settings.priorityBrowserIds.move(fromOffsets: source, toOffset: destination)
                            appState.updateSettings(appState.settings)
                        }
                    }
                    .frame(height: 120)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(NSColor.separatorColor), lineWidth: 1))
                    
                    Menu {
                        ForEach(appState.browserManager.availableBrowsers.filter({ !appState.settings.priorityBrowserIds.contains($0.id) })) { browser in
                            Button(action: {
                                appState.settings.priorityBrowserIds.append(browser.id)
                                appState.updateSettings(appState.settings)
                            }) {
                                Text(browser.displayName)
                            }
                        }
                    } label: {
                        Label("Add Browser", systemImage: "plus")
                    }
                    .menuStyle(.borderlessButton)
                    .controlSize(.small)
                    .disabled(appState.browserManager.availableBrowsers.filter({ !appState.settings.priorityBrowserIds.contains($0.id) }).isEmpty)
                }
                .padding(.leading, 20)
                .padding(.bottom, 8)
            }
            
            Divider()
                .padding(.vertical, 4)
                
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fallback Browser")
                        .font(.subheadline)
                    Text("Browser to use when no rules match")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            
                Spacer()
                
                Picker("", selection: Binding(
                    get: { appState.settings.fallbackBrowserId },
                    set: { appState.setFallbackBrowser($0) }
                )) {
                    ForEach(appState.browserManager.availableBrowsers) { browser in
                        Label {
                            Text(browser.displayName)
                        } icon: {
                            if let icon = browser.getIcon() {
                                Image(nsImage: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                        .tag(browser.id)
                    }
                }
                .labelsHidden()
                .fixedSize()
                
                Button(action: {
                    appState.browserManager.refreshBrowsers()
                }) {
                    if appState.browserManager.isRefreshingBrowsers {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .buttonStyle(.borderless)
                .disabled(appState.browserManager.isRefreshingBrowsers)
                .help("Refresh browser list")
            }
        }
    }
}
