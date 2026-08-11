export const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000/api/v1";

export function authHeaders(token: string): HeadersInit {
  return { Authorization: `Bearer ${token}`, "Content-Type": "application/json" };
}

export async function api<T>(path: string, token: string, init: RequestInit = {}): Promise<T> {
  const response = await fetch(`${API_URL}${path}`, { ...init, headers: { ...authHeaders(token), ...init.headers } });
  if (response.status === 401) {
    sessionStorage.removeItem("admin_token");
    window.location.href = "/login";
    throw new Error("Sesión vencida");
  }
  if (!response.ok) throw new Error(`API ${response.status}`);
  return response.json() as Promise<T>;
}

export const sections = ["dashboard", "games", "content", "config", "versions"] as const;
export type Section = (typeof sections)[number];

