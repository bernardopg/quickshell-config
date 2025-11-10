# TODO - Melhorias UI do Painel de Configurações

## 🎨 Plano de Melhorias da UI

### **1. Melhorias na Barra de Título** ⭐

- [x] Adicionar botões de minimizar e maximizar (atualmente só tem fechar)
- [x] Corrigir funcionalidade de minimizar (usar hide() no Wayland)
- [x] Corrigir duplo clique necessário para maximizar
- [x] Implementar arrastar janela pela barra de título
- [x] Adicionar duplo clique na barra de título para maximizar
- [x] Habilitar suporte a tiling (flag Qt.Window)
- [ ] Adicionar ícone da aplicação ao lado do título
- [x] Implementar barra de busca/filtro de configurações no header
- [ ] Adicionar indicador de mudanças não salvas (se aplicável)

### **2. Aprimorar o Navigation Rail** 🚀

- [ ] Adicionar badges/notificações em itens (ex: "Novo" na página About)
- [ ] Implementar submenus/grupos de navegação colapsáveis
- [ ] Adicionar separadores visuais entre grupos lógicos de páginas
- [ ] Melhorar feedback visual ao trocar de página (loading skeleton?)

### **3. Melhorias no Content Container** 📄

- [ ] Adicionar breadcrumbs para navegação contextual
- [ ] Implementar scroll indicator/progress bar
- [ ] Adicionar botão "Voltar ao topo" quando scrollar muito
- [ ] Criar header fixo em cada página com título e ações rápidas
- [ ] Adicionar animação de esqueleto durante carregamento de páginas

### **4. Sistema de Busca Global** 🔍

- [x] Campo de busca que filtra todas as configurações
- [x] Highlights em resultados de busca
- [x] Navegação rápida entre resultados (Ctrl+K para abrir)
- [ ] Histórico de buscas recentes

### **5. Melhorias de Acessibilidade** ♿

- [ ] Adicionar atalhos de teclado visíveis (ex: Alt+1 para primeira página)
- [ ] Melhorar contraste de cores em modo escuro
- [ ] Adicionar tooltips em todos os botões
- [ ] Suporte completo a navegação por teclado (Tab, Arrow keys)
- [ ] Indicador visual de foco mais claro

### **6. Footer/Bottom Bar** 📊

- [ ] Adicionar barra inferior com:
  - Status de sync/salvamento
  - Botão "Restaurar padrões" global
  - Botão "Exportar/Importar configurações"
  - Versão da aplicação

### **7. Animações e Transições** 🎭

- [ ] Melhorar animação de troca de páginas (mais fluida)
- [ ] Adicionar micro-interações nos switches/botões
- [ ] Implementar skeleton loading para conteúdo pesado
- [ ] Adicionar haptic feedback visual ao clicar

### **8. Sistema de Notificações/Feedback** 💬

- [ ] Toast notifications para confirmações (ex: "Configuração salva")
- [ ] Avisos de mudanças que requerem reinicialização
- [ ] Indicador de configurações experimentais
- [ ] Sistema de dicas contextuais

### **9. Melhorias Visuais** 🎨

- [ ] Adicionar glassmorphism/blur no navigation rail
- [ ] Melhorar cards das seções com elevação/sombras sutis
- [ ] Adicionar modo compacto/confortável (densidade de informação)
- [ ] Temas customizáveis além de claro/escuro
- [ ] Adicionar ilustrações/ícones maiores nas páginas vazias

### **10. Features Avançadas** 🔧

- [ ] Sistema de perfis de configuração (Gaming, Work, etc)
- [ ] Comparação lado a lado de configurações
- [ ] Timeline de mudanças (histórico de alterações)
- [ ] Modo "Expert" com configurações avançadas ocultas
- [ ] Dashboard inicial com resumo de configurações importantes

---

## 🚀 Prioridades Recomendadas

### **FASE 1 - Quick Wins** (Impacto Alto, Esforço Baixo)

1. ✅ Adicionar botões minimizar/maximizar na titlebar
2. ✅ Implementar busca de configurações
3. 📊 Adicionar footer com status e ações globais
4. 💬 Sistema de toast notifications

### **FASE 2 - Melhorias de UX** (Impacto Alto, Esforço Médio)

5. 🎨 Melhorar animações de transição entre páginas
6. ♿ Adicionar atalhos de teclado visíveis
7. 📄 Adicionar breadcrumbs e scroll indicator
8. 🎭 Implementar skeleton loading

### **FASE 3 - Features Avançadas** (Impacto Médio, Esforço Alto)

9. 🔧 Sistema de perfis de configuração
10. 📈 Timeline de mudanças

---

## 📝 Notas de Implementação

### Arquivos Principais

- `settings.qml` - Janela principal de configurações
- `modules/settings/*.qml` - Páginas individuais de configuração
- `modules/common/widgets/*.qml` - Componentes reutilizáveis

### Componentes Disponíveis

- `NavigationRail` - Rail de navegação lateral
- `NavigationRailButton` - Botões do rail
- `FloatingActionButton` - FAB personalizado
- `RippleButton` - Botão com efeito ripple
- `ContentPage` - Container de página de conteúdo
- `ContentSection` - Seção de conteúdo com título

### Sistema de Temas

- `Appearance.m3colors.*` - Cores Material 3
- `Appearance.colors.*` - Cores customizadas
- `Appearance.rounding.*` - Raios de borda
- `Appearance.animation.*` - Animações
- `Appearance.font.*` - Tipografia

### Internacionalização

- Usar `Translation.tr("texto")` para todas as strings

---

## ✅ Concluído

- Sistema básico de navegação
- Páginas de configuração modulares
- Suporte a temas claro/escuro
- FAB com ações principais
- Animações de transição entre páginas
- Suporte a atalhos de teclado básicos (Ctrl+PageUp/Down, Ctrl+Tab)
