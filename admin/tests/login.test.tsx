import React from "react";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import LoginPage from "@/app/login/page";

const replace = vi.fn();
vi.mock("next/navigation", () => ({ useRouter: () => ({ replace }) }));

describe("login", () => {
  beforeEach(() => { vi.restoreAllMocks(); sessionStorage.clear(); });
  it("stores a valid token and enters the dashboard", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({ ok: true, json: async () => ({ access_token: "token" }) }));
    render(<LoginPage />);
    fireEvent.change(screen.getByLabelText("Correo"), { target: { value: "admin@example.test" } });
    fireEvent.change(screen.getByLabelText("Contraseña"), { target: { value: "correct-password" } });
    fireEvent.click(screen.getByRole("button", { name: "Ingresar" }));
    await waitFor(() => expect(sessionStorage.getItem("admin_token")).toBe("token"));
    expect(replace).toHaveBeenCalledWith("/");
  });
  it("shows a safe message for invalid credentials", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({ ok: false }));
    render(<LoginPage />);
    fireEvent.change(screen.getByLabelText("Correo"), { target: { value: "admin@example.test" } });
    fireEvent.change(screen.getByLabelText("Contraseña"), { target: { value: "wrong-password" } });
    fireEvent.click(screen.getByRole("button", { name: "Ingresar" }));
    expect(await screen.findByRole("alert")).toHaveTextContent("Credenciales incorrectas");
  });
});
