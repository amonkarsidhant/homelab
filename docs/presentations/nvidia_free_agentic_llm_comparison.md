# NVIDIA Free Endpoint LLMs for Agentic SWE (Practical Ranking)

> Note: NVIDIA does **not** publish endpoint-specific benchmark scorecards for each free endpoint variant.
> Ranking below combines practical behavior + public model-family signals.

| Rank | Model | Agentic SWE fit | Benchmark transparency | Best use |
|---|---|---|---|---|
| 1 | `step-3.5-flash` | Best speed/quality balance | No endpoint-specific public score | Default agent model |
| 2 | `qwen3.5-122b-a10b` | Strong reasoning + coding, slower | Model-family benchmarks available; endpoint-specific not public | Deep code analysis |
| 3 | `nvidia-reasoning` (DeepSeek-R1 based) | Excellent reasoning, high latency | Public DeepSeek-R1 papers exist; endpoint-specific not public | Hard reasoning tasks |
| 4 | `minimax-m2.1` | Fast helper, weaker SWE depth | Limited transparent SWE benchmark data | Lightweight assistant tasks |

## Recommended stack
1. Default: `step-3.5-flash`
2. Escalate: `qwen3.5-122b-a10b`
3. Hard reasoning: `nvidia-reasoning`
4. Utility/fast chat: `minimax-m2.1`
