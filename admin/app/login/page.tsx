"use client";
import { FormEvent, useState } from "react";
import { useRouter } from "next/navigation";
import { API_URL } from "@/lib/api";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  async function submit(event: FormEvent) {
    event.preventDefault(); setBusy(true); setError("");
    try {
      const response = await fetch(`${API_URL}/admin/auth/login`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ email, password }) });
      if (!response.ok) throw new Error();
      const body = await response.json(); sessionStorage.setItem("admin_token", body.access_token); router.replace("/");
    } catch { setError("Credenciales incorrectas"); } finally { setBusy(false); }
  }
  return <main className="login-shell"><form className="login-card" onSubmit={submit}>
    <div className="brand-mark">G</div><h1>GenGames</h1><p>Panel administrativo privado</p>
    <label>Correo<input type="email" required value={email} onChange={e => setEmail(e.target.value)} /></label>
    <label>Contraseña<input type="password" required minLength={8} value={password} onChange={e => setPassword(e.target.value)} /></label>
    {error && <div className="error" role="alert">{error}</div>}
    <button className="primary" disabled={busy}>{busy ? "Ingresando…" : "Ingresar"}</button>
  </form></main>;
}

