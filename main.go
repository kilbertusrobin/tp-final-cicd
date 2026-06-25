package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

var version = "dev"

type healthResponse struct {
	Status string `json:"status"`
}

type rootResponse struct {
	Message string `json:"message"`
	Version string `json:"version"`
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	resp := rootResponse{
		Message: "Hello from CI/CD TP final",
		Version: version,
	}
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		http.Error(w, "internal server error", http.StatusInternalServerError)
		return
	}
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	resp := healthResponse{Status: "ok"}
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		http.Error(w, "internal server error", http.StatusInternalServerError)
		return
	}
}

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/", rootHandler)
	mux.HandleFunc("/healthz", healthHandler)

	port := "8080"
	fmt.Printf("Starting server on port %s (version: %s)\n", port, version)
	log.Fatal(http.ListenAndServe(":"+port, mux))
}
