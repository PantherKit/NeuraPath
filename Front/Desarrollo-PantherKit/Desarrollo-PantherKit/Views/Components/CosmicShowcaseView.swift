//
//  CosmicShowcaseView.swift
//  Desarrollo-PantherKit - Design System Showcase
//
//  Created on 5/11/25.
//

import SwiftUI

/// Showcase view for the Cosmic Glassmorphism Design System
/// Use this for development, testing, and demonstrating the design consistency
struct CosmicShowcaseView: View {
    @State private var showToast = false
    @State private var showModal = false
    @State private var textFieldValue = ""
    @State private var progressValue: Double = 0.7
    @State private var selectedGlassLevel: AppTheme.GlassLevel = .secondary
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Layout.spacingXL) {
                    // Header
                    headerSection
                    
                    // Typography showcase
                    typographySection
                    
                    // Glass cards showcase
                    glassCardsSection
                    
                    // Button showcase
                    buttonsSection
                    
                    // Interactive components
                    interactiveSection
                    
                    // Loading and feedback
                    feedbackSection
                    
                    // Info cards
                    infoCardsSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, AppTheme.Layout.spacingL)
                .padding(.top, AppTheme.Layout.spacingXL)
            }
        }
        .cosmicBackground()
        .overlay(
            // Toast overlay
            VStack {
                if showToast {
                    CosmicToast(
                        message: "¡Sistema de diseño Cosmic Glassmorphism!",
                        icon: "sparkles",
                        type: .info,
                        isShowing: $showToast
                    )
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer()
            }
        )
        .sheet(isPresented: $showModal) {
            modalContent
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: AppTheme.Layout.spacingL) {
            Text("🌌 Cosmic Glassmorphism")
                .cosmicTitle(AppTheme.Typography.largeTitle)
                .intensiveGlow()
            
            Text("Sistema de Diseño Unificado")
                .cosmicHeadline()
                .subtleGlow(color: AppTheme.Colors.cosmicBlue)
            
            Text("Interfaz espacial con glassmorphism moderno para NeuraPath")
                .cosmicBody()
                .multilineTextAlignment(.center)
        }
        .primaryGlassCard()
    }
    
    private var typographySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Layout.spacingL) {
            Text("🔤 Tipografía Cósmica")
                .cosmicTitle(AppTheme.Typography.title2)
            
            VStack(alignment: .leading, spacing: AppTheme.Layout.spacingM) {
                Text("Título Principal")
                    .cosmicTitle()
                
                Text("Headline Secundario")
                    .cosmicHeadline()
                
                Text("Body text para contenido principal y descripciones detalladas que necesiten más espacio")
                    .cosmicBody()
                
                Text("Caption para información secundaria")
                    .cosmicCaption()
            }
        }
        .secondaryGlassCard()
    }
    
    private var glassCardsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Layout.spacingL) {
            Text("🔮 Glass Cards")
                .cosmicTitle(AppTheme.Typography.title2)
            
            // Glass level picker
            HStack(spacing: AppTheme.Layout.spacingM) {
                Text("Nivel:")
                    .cosmicBody()
                
                Picker("Glass Level", selection: $selectedGlassLevel) {
                    Text("Primary").tag(AppTheme.GlassLevel.primary)
                    Text("Secondary").tag(AppTheme.GlassLevel.secondary)
                    Text("Tertiary").tag(AppTheme.GlassLevel.tertiary)
                    Text("Minimal").tag(AppTheme.GlassLevel.minimal)
                }
                .pickerStyle(.segmented)
            }
            
            // Sample card with selected level
            VStack(spacing: AppTheme.Layout.spacingM) {
                Text("Card de Ejemplo")
                    .cosmicHeadline()
                
                Text("Este es un ejemplo de card con glassmorphism aplicado. El nivel de transparencia y tinte cambia según la selección.")
                    .cosmicBody()
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(AppTheme.Colors.cosmicCyan)
                    Text("Elemento con ícono")
                        .cosmicBody()
                    Spacer()
                }
            }
            .glassCard(level: selectedGlassLevel)
        }
        .secondaryGlassCard()
    }
    
    private var buttonsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Layout.spacingL) {
            Text("🚀 Botones Cósmicos")
                .cosmicTitle(AppTheme.Typography.title2)
            
            VStack(spacing: AppTheme.Layout.spacingM) {
                // Cosmic Glass Buttons
                CosmicGlassButton(
                    title: "Botón Primary",
                    icon: "rocket.fill",
                    style: .primary,
                    size: .medium,
                    isFullWidth: true
                ) {
                    showToast = true
                }
                
                CosmicGlassButton(
                    title: "Botón Secondary",
                    icon: "star.circle",
                    style: .secondary,
                    size: .medium,
                    isFullWidth: true
                ) {
                    showModal = true
                }
                
                HStack(spacing: AppTheme.Layout.spacingM) {
                    CosmicGlassButton(
                        title: "Minimal",
                        style: .minimal,
                        size: .small
                    ) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    
                    CosmicGlassButton(
                        title: "Destructive",
                        icon: "trash",
                        style: .destructive,
                        size: .small
                    ) {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    }
                }
                
                // Extension-based buttons
                Text("Con Extension")
                    .cosmicPrimaryButton()
                    .hapticFeedback()
                
                Text("Glass Button")
                    .cosmicGlassButton()
                    .hapticFeedback()
            }
        }
        .secondaryGlassCard()
    }
    
    private var interactiveSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Layout.spacingL) {
            Text("⚡ Componentes Interactivos")
                .cosmicTitle(AppTheme.Typography.title2)
            
            VStack(spacing: AppTheme.Layout.spacingL) {
                // Text Field
                CosmicGlassTextField(
                    title: "Campo de Texto",
                    placeholder: "Escribe algo aquí...",
                    text: $textFieldValue,
                    icon: "person.fill"
                )
                
                // Progress View
                VStack(alignment: .leading, spacing: AppTheme.Layout.spacingS) {
                    Text("Progreso Cósmico")
                        .cosmicHeadline(AppTheme.Typography.subheadline)
                    
                    CosmicGlassProgressView(
                        progress: progressValue,
                        showParticles: true
                    )
                    .frame(height: 12)
                    
                    HStack {
                        Button("Disminuir") {
                            withAnimation(.spring()) {
                                progressValue = max(0, progressValue - 0.2)
                            }
                        }
                        .cosmicGlassButton()
                        
                        Spacer()
                        
                        Button("Aumentar") {
                            withAnimation(.spring()) {
                                progressValue = min(1, progressValue + 0.2)
                            }
                        }
                        .cosmicGlassButton()
                    }
                }
            }
        }
        .secondaryGlassCard()
    }
    
    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Layout.spacingL) {
            Text("💫 Feedback y Loading")
                .cosmicTitle(AppTheme.Typography.title2)
            
            VStack(spacing: AppTheme.Layout.spacingL) {
                // Loading view
                CosmicLoadingView(
                    message: "Cargando el futuro...",
                    showParticles: true
                )
                .frame(height: 150)
                
                // Buttons to trigger toasts
                HStack(spacing: AppTheme.Layout.spacingM) {
                    Button("Toast Info") {
                        showToast = true
                    }
                    .cosmicGlassButton()
                }
            }
        }
        .secondaryGlassCard()
    }
    
    private var infoCardsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Layout.spacingL) {
            Text("📋 Info Cards")
                .cosmicTitle(AppTheme.Typography.title2)
            
            VStack(spacing: AppTheme.Layout.spacingM) {
                CosmicInfoCard(
                    title: "Análisis STEM",
                    subtitle: "Descubre tu perfil vocacional",
                    icon: "brain.head.profile",
                    iconColor: AppTheme.Colors.cosmicCyan
                ) {
                    showModal = true
                }
                
                CosmicInfoCard(
                    title: "Resultados",
                    subtitle: "Visualiza tus carreras recomendadas",
                    icon: "chart.bar.fill",
                    iconColor: AppTheme.Colors.cosmicPurple
                ) {
                    showToast = true
                }
                
                CosmicInfoCard(
                    title: "Configuración",
                    subtitle: "Personaliza tu experiencia",
                    icon: "gearshape.fill",
                    iconColor: AppTheme.Colors.cosmicBlue
                ) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
        }
        .secondaryGlassCard()
    }
    
    // MARK: - Modal Content
    
    private var modalContent: some View {
        CosmicModal(
            isPresented: $showModal,
            title: "Modal Cósmico",
            showCloseButton: true
        ) {
            VStack(spacing: AppTheme.Layout.spacingL) {
                Text("🌟 Este es un modal con glassmorphism")
                    .cosmicHeadline()
                    .multilineTextAlignment(.center)
                
                Text("Los modales utilizan el mismo sistema de diseño, manteniendo la cohesión visual en toda la aplicación.")
                    .cosmicBody()
                    .multilineTextAlignment(.center)
                
                CosmicGlassButton(
                    title: "Entendido",
                    icon: "checkmark",
                    style: .primary,
                    size: .medium,
                    isFullWidth: true
                ) {
                    showModal = false
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    CosmicShowcaseView()
        .preferredColorScheme(.dark)
} 