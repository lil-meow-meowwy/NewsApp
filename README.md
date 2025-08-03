# NewsApp - iOS News Reader

A modern iOS news application built with SwiftUI, Core Data, and the NewsAPI, featuring real-time news browsing, favorites system, and category filtering.

## Features

- **Latest News Feed**: Browse top headlines with infinite scrolling
- **Search Functionality**: Find news by keywords
- **Categories**: Filter by business, technology, sports, etc.
- **Favorites System**: Save articles for offline reading
- **Dark/Light Mode**: Full system appearance support
- **Core Data Integration**: Persistent storage for favorites

## Tech Stack

- **Architecture**: MVVM (Model-View-ViewModel)
- **UI Framework**: SwiftUI
- **State Management**: Combine + @Published properties
- **Persistence**: Core Data with background context
- **Networking**: Async/Await with URLSession
- **Dependencies**: 
  - [NewsAPI](https://newsapi.org/) for news data
  - SwiftUI Refreshable for pull-to-refresh

## Demo

Demo: [Google Drive](https://drive.google.com/file/d/1xQ7-AJIVen3gAQNaJbm0BboRcLjry9AE/view?usp=sharing)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/lil-meow-meowwy/NewsApp.git
```

2. Get API key from NewsAPI and add to:
```
// NewsService.swift
private let apiKey = "YOUR_API_KEY_HERE"
```

3. Open NewsApp.xcodeproj and build (⌘B)


## Contributing

Pull requests are welcome! For major changes, please open an issue first.

## License

MIT
