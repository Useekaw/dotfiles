---
name: quick
description: Leichtgewichtiger Workflow für Schnellschuss-Projekte nach dem Elephant-Goldfish-Prinzip. Intent im Gespräch klären, vom User freigeben lassen, dann ein Subagent ohne Chatkontext (Goldfish) auf "gibt es das schon / geht es einfacher / ergibt es Sinn", danach bauen und ein zweiter Goldfish als Review. Trigger: /quick, "Schnellschuss", "kleines Projekt bauen", "neues Tool/Skript/Workflow bauen". Nicht für Bugfixes oder Einzeiler.
---

# /quick – Elephant-Goldfish lite

Du bist der Elephant: du kennst das Gespräch. Goldfische sind Subagents, die **nur den Brief** (und beim Review den Bau-Output) sehen, nie den Chat. Das ist der Zweck: sie sollen Annahmen finden, die du und der User nicht mehr sehen.

Ablauf strikt in dieser Reihenfolge. Nie eine Phase überspringen, ohne dass der User es sagt.

## Phase 1: Intent (Gespräch)

- Ziel: gemeinsam klären, was gebaut werden soll und warum.
- **Immer nur eine Frage pro Nachricht.** Dann auf die Antwort warten. Keine Fragenlisten, keine Mehrfachfragen.
- So viele Fragen wie nötig. Nicht abkürzen, um fertig zu werden.
- Bei Ambiguität lieber nachfragen als raten. Typische Themen: Problem dahinter, wer nutzt es, Nicht-Ziele, Rahmenbedingungen (wo läuft es, womit integriert es sich), was "fertig" bedeutet.
- Eigenes Wissen (Vault, Homelab, Memory) vorher nutzen, damit keine Fragen gestellt werden, die schon beantwortet sind.

## Phase 2: Brief + Freigabe durch den User

- Schreibe den Brief nach `.quick/brief.md` im aktuellen Projektverzeichnis (Ordner anlegen falls nötig).
- Länge: so kurz wie möglich, so lang wie nötig. Ein Fremder ohne Chat muss ihn verstehen.
- Inhalt: Ziel und Motivation, Nicht-Ziele, Rahmenbedingungen/Umgebung, Akzeptanzkriterien, offene Annahmen (explizit als Annahme markieren).
- Zeige den Brief dem User und **warte auf ausdrückliche Freigabe oder Korrekturen**. Nichts an einen Goldfisch geben, bevor der User freigegeben hat. Korrekturen einarbeiten und erneut zeigen.

## Phase 3: Goldfish "Sinnprüfung"

Starte einen Subagent (Agent-Tool, `subagent_type: general-purpose`, `model: opus`; die Prüfung ist Urteilsarbeit). Er bekommt **nur** den Pfad zum Brief und diese Aufgabe, nichts aus dem Chat:

> Lies `<absoluter Pfad>/.quick/brief.md`. Du hast keinen weiteren Kontext, und das ist Absicht. Prüfe unabhängig:
> 1. Gibt es das schon? Suche gründlich: im Projektverzeichnis und im lokalen Umfeld (Dateisystem, Git-Repos, wenn verfügbar Vault/Forgejo/n8n/Coolify) sowie im Web (GitHub, Paketregister, Doku). Nenne konkrete Treffer mit Link/Pfad.
> 2. Geht es einfacher? Z. B. vorhandenes Tool mit Konfiguration, Einzeiler, bestehender Workflow, kleinerer Umfang.
> 3. Ergibt es Sinn? Passen Aufwand und Nutzen, widersprechen sich Ziele oder Annahmen, fehlt etwas Wesentliches?
> Urteil: **BAUEN**, **STATTDESSEN <X>** oder **LASSEN**, danach höchstens 5 Zeilen Begründung, danach Liste der Annahmen im Brief, die du für falsch oder ungeprüft hältst. Sei konkret, nicht höflich. Ändere keine Dateien außer eigenen Notizen unter `.quick/`.

Gib dem User das Urteil **ungekürzt und ohne Beschönigung** wieder. Der Goldfisch empfiehlt, der User entscheidet. Bei STATTDESSEN/LASSEN: Optionen nennen und fragen, wie es weitergeht. Bei BAUEN mit Einwänden: Brief anpassen (wieder mit Freigabe des Users).

## Phase 4: Bauen

- Du baust (Main-Agent), strikt im Rahmen des freigegebenen Briefs. Kein Scope-Creep. Wenn du etwas Neues entscheiden musst, das nicht im Brief steht: den User fragen (eine Frage).
- Vorhandenes wiederverwenden (siehe Fund des Goldfischs).
- Teste, soweit sinnvoll, selbst, bevor du zum Review übergibst.

## Phase 5: Goldfish "Review"

Starte einen zweiten, **frischen** Subagent (`general-purpose`, `model: sonnet`). Er bekommt nur: Pfad zum Brief, Pfad zum Projekt (oder Diff), diese Aufgabe:

> Lies `<Pfad>/.quick/brief.md` und prüfe das Ergebnis in `<Pfad>`. Du kennst die Entstehung nicht, und das ist Absicht. Prüfe:
> 1. Erfüllt das Ergebnis jedes Akzeptanzkriterium aus dem Brief? Einzeln abhaken.
> 2. Offensichtliche Fehler, Sicherheitsprobleme (Secrets im Code, offene Ports, fehlende Auth), kaputte Pfade.
> 3. Scope-Creep: Dinge, die nicht im Brief stehen.
> Liste höchstens 8 Findings, je Zeile `Datei:Zeile – Problem – Fix`, absteigend nach Schwere. Wenn nichts: "keine Findings". Ändere nichts am Projekt.

Gib dem User die Findings wieder. Behebe unstrittige selbst. Frage bei strittigen. Zum Schluss: kurz berichten, was gebaut wurde, was der Goldfisch fand, was offen ist.

## Modellwahl

- Intent-Gespräch und Bau laufen im Modell der laufenden Session. Der Intent profitiert am meisten vom starken Modell, der Bau bei gutem Brief weniger. Wenn möglich: Session mit starkem Modell starten, für den Bau reicht ein schwächeres (`/model`), falls der User wechseln will. Nicht selbst wechseln.
- Sinnprüfung: starkes Modell (Urteil, Recherche). Review: Sonnet reicht.

## Überspringen

- Bugfixes, Einzeiler und klare Kleinänderungen: `/quick` nicht verwenden.
- Auf Zuruf des Users einzelne Phasen auslassen (z. B. "Review brauchst du nicht"). Nie von selbst.
