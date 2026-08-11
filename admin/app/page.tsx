"use client";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { Section, sections } from "@/lib/api";
import { Dashboard } from "@/components/dashboard";
import { Games } from "@/components/games";
import { Content } from "@/components/content";
import { Configuration } from "@/components/configuration";
import { Versions } from "@/components/versions";

const labels: Record<Section, string> = { dashboard: "Resumen", games: "Juegos", content: "Contenido", config: "Configuración", versions: "Versiones" };
export default function AdminPage() {
  const router = useRouter(); const [token, setToken] = useState<string>(); const [section, setSection] = useState<Section>("dashboard");
  useEffect(() => { const saved = sessionStorage.getItem("admin_token"); if (!saved) router.replace("/login"); else setToken(saved); }, [router]);
  if (!token) return <main className="loading">Cargando…</main>;
  const views: Record<Section, React.ReactNode> = { dashboard: <Dashboard token={token}/>, games: <Games token={token}/>, content: <Content token={token}/>, config: <Configuration token={token}/>, versions: <Versions token={token}/> };
  return <div className="admin-shell"><aside><div className="sidebar-brand"><span>G</span><strong>GenGames</strong></div><nav>{sections.map(item => <button key={item} className={section === item ? "active" : ""} onClick={() => setSection(item)}>{labels[item]}</button>)}</nav><button className="logout" onClick={() => { sessionStorage.clear(); router.replace("/login"); }}>Cerrar sesión</button></aside><main className="workspace"><header><div><small>ADMINISTRACIÓN</small><h1>{labels[section]}</h1></div><span className="environment">DEVELOPMENT</span></header>{views[section]}</main></div>;
}

