# Gem Harvest Idle - Claude Code Context

**Last Updated:** December 29, 2025

## Project Overview
Mobile idle RPG with gacha mechanics targeting Southeast Asia.
Tactical Idle concept: passive farming + micro-roguelike rift runs.
PDPA compliant from day one for Singapore market.

## Technical Stack (Updated Dec 2025)

| Component | Technology | Purpose |
|-----------|------------|---------|
| Engine | Godot 4.5 | Game client (GDScript only) |
| Game Backend | Nakama 3.x | Gacha, economy, multiplayer, anti-cheat |
| Analytics/Auth | Supabase | Analytics, auth backup, real-time |
| Database | PostgreSQL 16 | Primary data store |
| Cache | Redis 7 | Session cache, rate limiting |
| Production Host | AWS Singapore | Multi-AZ, 99.99% SLA |
| Dev/Staging | Fly.io Singapore | Cost-effective containers |
| CDN | CloudFlare | Edge cache, DDoS protection |

## Target Platforms
- Android: API 35 (target), API 24 (min)
- iOS: iOS 18 SDK (build), iOS 15 (min)
- Performance: 30 FPS on 2GB RAM devices, 60 FPS on 4GB+

## Coding Standards

### GDScript Rules
- ALWAYS use typed GDScript (static typing)
- Use @export for inspector variables
- Use signals for component communication
- Use Resources for data definitions
- Prefix private methods with underscore: _private_method()
- Use class_name for all classes

### Naming Conventions
- Files: snake_case.gd
- Classes: PascalCase
- Functions: snake_case()
- Variables: snake_case
- Constants: SCREAMING_SNAKE_CASE
- Signals: past_tense (e.g., hero_died, gem_collected)

### Architecture Patterns
- Autoload singletons for global managers
- State machines for complex game states
- Command pattern for player actions
- Observer pattern via Godot signals
- Object pooling for frequently spawned objects

## Security Rules (CRITICAL)
- ALL currency calculations happen SERVER-SIDE (Nakama)
- Client NEVER determines gacha results
- Validate ALL IAP receipts on server
- Never trust client-sent values for economy
- Rate-limit all server requests
- Encrypt all local save data (AES-256)
- Show PDPA consent before ANY data collection

## SEA Market Adaptations
- Support digital wallets: GCash, TrueMoney, MoMo, OVO
- Optimize for low-end devices (2GB RAM)
- Download size under 300MB
- Offline mode for idle progression
- Localization: EN, ID, TH, VI, TL

## Current Sprint
Week 1 - Project Setup
Focus: Initialize Godot project structure and create placeholder files
Priority: Get the skeleton in place, no logic yet

## Known Issues
None yet

## File Dependencies
When modifying these files, check dependencies:
- game_manager.gd -> affects all systems
- save_manager.gd -> affects data persistence
- network_manager.gd -> affects server communication
- consent_manager.gd -> affects data collection legality
