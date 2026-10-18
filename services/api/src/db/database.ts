import { Pool, type PoolClient, type QueryResultRow } from 'pg';

export type Queryable = Pick<PoolClient, 'query'>;

/** Тонкая обёртка над пулом соединений PostgreSQL. */
export class Database {
  constructor(readonly pool: Pool) {}

  static connect(url: string): Database {
    return new Database(new Pool({ connectionString: url, max: 10 }));
  }

  async query<T extends QueryResultRow>(sql: string, params: unknown[] = []): Promise<T[]> {
    const result = await this.pool.query<T>(sql, params);
    return result.rows;
  }

  /** Выполняет [work] в одной транзакции; при ошибке всё откатывается. */
  async transaction<T>(work: (tx: Queryable) => Promise<T>): Promise<T> {
    const client = await this.pool.connect();
    try {
      await client.query('BEGIN');
      const result = await work(client);
      await client.query('COMMIT');
      return result;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  close(): Promise<void> {
    return this.pool.end();
  }
}
