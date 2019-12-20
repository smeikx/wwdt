# Einleitung


**Der Tisch** ist ein System, das den kreativen Prozess innerhalb eines Projektes unterstützt. Er zeichnet Gruppendiskussionen auf und dient Teilnehmerinnen und Teilnehmern als gemeinsame Datensammelstelle. Er ermöglicht es, erfasste Daten zu betrachten, miteinander in Verbindung zu setzen und auszuwerten.

In seiner Erstform wird **Der Tisch** primär im Unterricht an Gestaltungshochschulen genutzt. Allerdings wird beim Entwurf auch die Nutzung in anderem Kontext berücksichtigt.

Obwohl **Der Tisch** einen Platz im Gestaltungsprozess einnimmt, hält er sich im direkten Austausch zwischen Gestalterinnen und Gestaltern im Hintergrund – er versucht nicht, vertraute Werkzeuge zu ersetzen. 

Ein erklärtes Ziel besteht darin, während Diskussionen aufgekommene Informationen schnell wiederfinden zu können. 



# Daten

> Als `Code` ausgezeichnete Begriffe beschreiben übergreifend genutzte Datentypen, sie entsprechen der tatsächlichen Bezeichnung in der Datenbank.
> *Hervorgehobene* Begriffe beschreiben lokalere Daten und weichen von der Bezeichnung in der Datenbank ab.


## `Project`

Der größte Datenbehälter ist das `Project`; es hat zumindest einen Titel und ein Erstellungsdatum, optional auch eine Beschreibung. Pro `Project` können mehrere `Sessions` angelegt werden.


## `Contributors`

Benutzerinnen und Benutzer, hier `Contributors` genannt, existieren projektübergreifend. Jedem `Contributor` kann eine Rolle zugewiesen werden; die einzige notwendige Rolle ist jene der *Session-Leitung*: Sie konfiguriert, startet und beendet `Sessions`. Die *Session-Leitung* hat außerdem erweiterte Berechtigungen.


## `Sessions`

Eine `Session` umfasst sämtliche Daten, die während und nach einer Diskussion entstehen – inkl. den Beziehungen die zwischen diesen Daten hergestellt werden. Dazu zählen:

- Video- und Ton-Aufzeichnungen
- `Markers` (zeitgebundene Datenbehälter)
- beliebige Uploads
- `Arrangements` (hergestellte Beziehungen zwischen Daten)

### `Markers`

Bei `Markers` handelt es sich um Datenbehälter, die zumindest aus einem *Timestamp* und einem *Titel* bestehen. Weiters können sie eine *Beschreibung, Tags, URLs* und *Uploads* beinhalten.

Jeder *Upload* wird automatisch an einen `Marker` gebunden, ein *Upload* kann aber beliebig oft von anderen `Markers` referenziert werden.

### `Arrangements`

In einem `Arrangement` werden bestehende `Markers` referenziert und (von Zeit ungebunden) zweidimensional angeordnet. Zweck eines `Arrangements` ist es, Beziehungen zwischen `Markers` auszudrücken – primär durch verschiedene Distanzen zueinander.

Neben `Markers` können auch *Labels* und *Verbindungen* erstellt und platziert werden. *Labels* bestehen aus einem *Titel* und einer optionalen *Beschreibung*, *Verbindungen* beschreiben lediglich zwei Positionen.

Die Platzierung von Daten ist an ein Raster gebunden: pro Zelle ein `Marker` oder *Label*. Das Raster kann theoretisch unbeschränkt erweitert werden.


## Zugriffsberechtigung

`Contributors` haben die Kontrolle über Sichtbarkeit und Bearbeitbarkeit ihrer Beiträge (`Markers` und `Arrangements`): Sie können wählen, wer welchen Beitrag sehen und wer ihn auch bearbeiten darf.

Möglicherweise gibt es Rollen, deren Träger sich über die individuell festgelegten Berechtigungen hinwegsetzen können. 
Die *Session-Leitung* kann zudem die Default-Berechtigung von neu erstellten Beiträgen festlegen.



# Ablauf


Um die Entwicklung des Systems zu erleichtern, wird die vorgesehene Nutzung des Systems in Phasen unterteilt. Diese Phasen wurden primär zur internen Kommunikation definiert, sie müssen sich nicht unmittelbar im GUI widerspiegeln. 

Die untenstehende Liste zeigt, welche Tätigkeiten in welcher Phase hauptsächlich stattfinden; allerdings ist nahezu jede Aktion zu jedem Zeitpunkt möglich.

Da die Phase *(4) Reflexion* praktisch einen Bestandteil der Phase *(5) Interpretation* darstellt, können die beiden Phasen vermutlich oft als eine betrachtet werden.

1. Vorbereitung
	- Anlegen von Projekt
	- Anlegen und Konfiguration von Session
	- Überprüfung von Recording-Geräten
	- Anlegen von Contributors
	- Anmelden von Geräten
2. Diskussion
	- Setzen von Markers
	- Upload von Dateien
3. Aufbereitung
	- Erweitern und Überarbeiten von Markers
	- Upload von Dateien
4. Reflexion ↓
	- Betrachtung von Inhalten
5. Interpretation ↑
	- Anlegen und Bearbeiten von Arrangements
6. Archivierung
	- Export autonomen Pakets

Eine Session wird nie explizit beendet, sie kann jederzeit weiter fortgeführt werden. 

