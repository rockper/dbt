with customers as (

    select * from {{ ref('stg_customers')}}

),

orders as (

    select * from {{ ref('stg_orders') }}

),

order_amounts as (

    select * from {{ ref('fct_orders') }}

),

customer_lifetimes as (

    select 
        customer_id,
        sum(amount) as lifetime_value

    from order_amounts
    group by 1


),

customer_orders as (

    select
        customer_id,

        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as number_of_orders

    from orders

    group by 1

),

final as (

    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        customer_lifetimes.lifetime_value,
        coalesce(customer_orders.number_of_orders, 0) as number_of_orders

    from customers

    left join customer_orders using (customer_id)
    left join customer_lifetimes using (customer_id)

)

select * from final