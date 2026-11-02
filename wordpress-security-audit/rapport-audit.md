# Rapport d'audit de sécurité — WordPress

**Date :** 2 novembre 2026  
**Périmètre :** installation WordPress du laboratoire personnel VirtualBox  
**Cible :** `192.168.2.5`  
**Machine d'audit :** Kali Linux  
**Outils :** Nmap, WhatWeb, WPScan, cURL

## 1. Objectif et autorisation

Évaluer une installation WordPress appartenant au laboratoire personnel : identifier les services et informations exposés, vérifier certaines mauvaises configurations, appliquer des mesures de durcissement et contrôler leur effet. Les tests ont été réalisés sur un environnement isolé et autorisé.

## 2. Environnement observé

| Élément | Valeur |
|---|---|
| Système serveur | Ubuntu Server |
| Serveur Web | Apache 2.4.41 |
| PHP | 7.4.3 |
| CMS | WordPress 7.1.4 (identification scanner) |
| Machine d'audit | Kali Linux |
| Adresse cible | 192.168.2.5 |

## 3. Méthodologie

Reconnaissance, énumération WordPress, vérification de configurations, tests HTTP contrôlés, durcissement Apache et des permissions, puis réaudit.

## 4. Constatations initiales

- Nmap a identifié SSH (22/tcp) et HTTP (80/tcp) ouverts ; HTTPS (443/tcp) fermé au moment du scan.
- Apache 2.4.41 et WordPress ont été identifiés.
- L'indexation de certains répertoires était activée, notamment `wp-content/uploads/` et un répertoire de thème.
- L'archive publique `readme.html` et le fichier `license.txt` étaient accessibles.
- L'énumération par archive auteur et par l'API REST a révélé des informations de profil utilisateur. Cela ne révèle pas un mot de passe et ne prouve pas une compromission.
- `wp-config.php` n'a pas livré son contenu dans les tests HTTP réalisés.
- `wp-content/debug.log` et `.git/config` ont répondu 404 aux chemins testés.
- PHP 7.4 est en fin de support ; une mise à niveau est recommandée.
- XML-RPC a répondu HTTP 405 à une requête GET ; ce seul test ne permet pas de conclure que XML-RPC est désactivé.

## 5. Mesures appliquées

- Désactivation de l'indexation des répertoires avec `Options -Indexes`.
- Refus de l'accès HTTP à `wp-config.php`.
- Permissions de `wp-config.php` : propriétaire `root`, groupe `www-data`, mode `640`.
- Réduction des informations de version Apache avec `ServerTokens Prod`.
- Désactivation de la signature Apache avec `ServerSignature Off`.

Une erreur HTTP 500 est survenue après une première modification des permissions de `wp-config.php`. Les journaux Apache ont montré un refus de lecture par le processus web. La propriété et les permissions ont été corrigées ; l'application a ensuite répondu normalement.

## 6. Réaudit du 2 novembre 2026

| Ressource / requête | Code HTTP | Résultat |
|---|---:|---|
| `/` | 200 | Application accessible |
| `/wp-login.php` | 200 | Connexion accessible |
| `/wp-config.php` | 403 | Accès HTTP interdit |
| `/wp-content/uploads/` | 403 | Indexation bloquée |
| `/wp-content/themes/twentytwentyfive/` | 403 | Indexation bloquée |
| `/xmlrpc.php` avec GET | 405 | Méthode GET non autorisée |
| `/index.php/wp-json/wp/v2/users?per_page=10` | 200 | API utilisateurs toujours accessible |

## 7. Risques résiduels et recommandations

1. **API REST / énumération :** évaluer si les profils utilisateurs doivent être publics et appliquer une restriction compatible avec les fonctionnalités du site.
2. **PHP obsolète :** préparer une mise à niveau vers une version maintenue, après sauvegarde et tests de compatibilité.
3. **Mises à jour :** mettre à jour WordPress, extensions et thèmes après sauvegarde et validation de compatibilité.
4. **XML-RPC :** déterminer si cette interface est nécessaire ; si elle ne l'est pas, la désactiver et vérifier le résultat avec les méthodes pertinentes.
5. **En-têtes HTTP :** examiner les en-têtes de sécurité et déployer une politique adaptée, testée pour éviter de casser le site.
6. **Maintenance :** mettre en place des sauvegardes, une surveillance des journaux et des audits périodiques.

## 8. Limites

Cet exercice est un audit pédagogique ciblé, pas un test d'intrusion exhaustif. Les codes HTTP décrivent uniquement les requêtes testées. Un 403 sur un répertoire indique que l'indexation ou l'accès à cette URL est refusé ; il ne prouve pas que tous les fichiers du répertoire sont inaccessibles. Un 405 sur XML-RPC pour GET ne prouve pas que toutes les méthodes sont désactivées.

## 9. Conclusion

Les contrôles ont permis de réduire l'exposition des répertoires et de protéger l'accès HTTP au fichier de configuration, tout en conservant l'accès au site et à la page de connexion. L'API REST utilisateurs demeure accessible et plusieurs recommandations restent à traiter, notamment la mise à niveau de PHP et les mises à jour des composants.

**Conclusion :** durcissement partiel appliqué et vérifié ; risques résiduels documentés.
