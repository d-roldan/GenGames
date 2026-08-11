import { describe, expect, it } from "vitest";
import { authHeaders, sections } from "@/lib/api";

describe("administrative features", () => {
  it("includes every required management section", () => {
    expect(sections).toEqual(["dashboard", "games", "content", "config", "versions"]);
  });
  it("protects API requests with the administrative bearer token", () => {
    expect(authHeaders("private-token")).toMatchObject({ Authorization: "Bearer private-token" });
  });
});

