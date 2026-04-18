package main

import (
	"database/sql"
	"fmt"
	"log"
	"time"

	_ "github.com/lib/pq"
)

func main() {
	dbURL := "postgresql://neondb_owner:npg_QVihFSKPEA10@ep-wild-tree-a9m1gwwx.gwc.azure.neon.tech/neondb?sslmode=require"
	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatalf("Error opening database: %v", err)
	}
	defer db.Close()

	// Check if user already exists
	var id string
	err = db.QueryRow("SELECT id FROM users WHERE id = 'system-user-id'").Scan(&id)
	if err == nil {
		fmt.Println("System user already exists.")
		return
	}

	// Insert system user
	now := time.Now()
	_, err = db.Exec(`
		INSERT INTO users (id, api_key, email, created_at, updated_at) 
		VALUES ($1, $2, $3, $4, $5)`,
		"system-user-id", "system-user-api-key", "system@httpsms.com", now, now)

	if err != nil {
		log.Fatalf("Error inserting system user: %v", err)
	}

	fmt.Println("System user created successfully.")
}
