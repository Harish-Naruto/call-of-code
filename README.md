# Call of Code — Public Website

The official website for the **Call of Code** programming club, built with **Next.js 15**, **React 18**, and **Tailwind CSS**.

---

## Tech Stack

| Layer      | Technology                              |
| ---------- | --------------------------------------- |
| Framework  | Next.js 15 (App Router)                 |
| Language   | TypeScript                              |
| Styling    | Tailwind CSS + Radix UI                 |
| Animations | Framer Motion                           |
| Runtime    | Node.js 20                              |
| API        | `coc-api` — pre-built Docker Hub image  |

---

## Local Development

### Prerequisites

- Node.js ≥ 20 and npm
- Git

### Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/callofcode07/call-of-code.git
   cd call-of-code
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment variables:**
   ```bash
   cp .env.example .env
   ```
   Open `.env` and fill in the required values:

   | Variable       | Description                            |
   | -------------- | -------------------------------------- |
   | `API_BASE_URL` | Base URL for the COC API (e.g. `http://localhost:3000`) |
   | `GITHUB_TOKEN` | GitHub personal access token (optional, for contribution data) |

4. **Run the development server:**
   ```bash
   npm run dev
   ```
   The app will be available at **http://localhost:3001**.

---

## Docker — Local Development

A fully containerised local environment (Next.js frontend + COC API) is available via Docker Compose.

See **[DOCKER.md](./DOCKER.md)** for the complete guide, including:
- One-command startup with hot-reload (`--watch` mode)
- Environment variable configuration
- Health checks and service dependencies

---

## Available Scripts

| Command           | Description                              |
| ----------------- | ---------------------------------------- |
| `npm run dev`     | Start Next.js dev server on port 3001    |
| `npm run build`   | Create a production build                |
| `npm run start`   | Serve the production build on port 3001  |
| `npm run lint`    | Run ESLint                               |

---

## Contributing

We welcome contributions from everyone!

1. **Fork** the repository and create a branch from `main`.
2. **Make your changes** with clear, descriptive commit messages.
3. **Push** your branch and open a **pull request**.
4. Ensure your code **passes linting** (`npm run lint`) and follows the project's coding standards.

---

## License

This project is licensed under the [GNU General Public License v3.0](./LICENSE).

---

## Contact

For questions or suggestions, open an issue or reach out at **callofcode07@gmail.com**.

Happy coding! 🚀
