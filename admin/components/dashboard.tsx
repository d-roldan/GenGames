"use client";
import { useEffect, useState } from "react";
import { api } from "@/lib/api";
type Data = { total_installations: number; active_installations: number; events: number; sessions: number; popular_games: {game: string; count: number}[]; recent_activity: {event: string; game?: string; at: string}[] };
export function Dashboard({token}: {token: string}) {
  const [data, setData] = useState<Data>(); const [error, setError] = useState("");
  useEffect(() => { api<Data>("/admin/dashboard", token).then(setData).catch(() => setError("No se pudo cargar el dashboard")); }, [token]);
  if (error) return <div className="error">{error}</div>; if (!data) return <div className="loading-card">Cargando métricas…</div>;
  return <><section className="metrics">{[["Instalaciones", data.total_installations], ["Activas", data.active_installations], ["Sesiones", data.sessions], ["Eventos", data.events]].map(([label, value]) => <article key={label}><span>{label}</span><strong>{value}</strong></article>)}</section><div className="two-columns"><section className="panel"><h2>Juegos más usados</h2>{data.popular_games.length ? data.popular_games.map(item => <div className="bar-row" key={item.game}><span>{item.game}</span><b>{item.count}</b></div>) : <p className="muted">Aún no hay actividad.</p>}</section><section className="panel"><h2>Actividad reciente</h2>{data.recent_activity.length ? data.recent_activity.map((item, i) => <div className="activity" key={i}><i/><div><strong>{item.event}</strong><small>{item.game ?? "aplicación"}</small></div></div>) : <p className="muted">Aún no hay eventos.</p>}</section></div></>;
}

