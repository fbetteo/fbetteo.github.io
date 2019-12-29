
# get info from fitted gam object
reporte_gam <- function(modelo, df){
  print(summary(modelo))
  ajustado <- cbind(modelo$model, modelo$residuals, modelo$fitted.values) %>%
    arrange(modelo$residuals)
  return(ajustado)
}


# Get partial effects of predictors
confidence_gam <- function(var_model,modelo){

  # calcula valor estimado e intervalos de confianza
  # para todos los puntos de la data asi queda prolijo
  # value es el eje X, la variable independiente
  # est es el impacto en Y
  # lower y upper son las bandas
  # dropee el SE y "crit"
  ci <- confint(modelo, parm = var_model ,type = "confidence",
                newdata = modelo$model[,var_model]) %>%
    gather(key = variable, value = value, var_model,
           -c(smooth,by_variable, est, se, crit, lower, upper)) %>%
    select(variable, value, est, lower, upper )

  #print(var_model)
  #print((ci))
  # Plot para chequeos
  #  ggplot(ci, aes_string(x = var_model, y = "est", group = "smooth")) +
  #    geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.3) +
  #    geom_line()  +
  #    facet_wrap( ~ smooth, scales = "free")

  return(ci)
}




# Get partial effects of predictors (DEPRECATED)
partial_effect <- function(var_model, modelo) {

  coef <- modelo$coefficients %>% as.data.frame() %>%
    rename(., coef = .) %>%
    mutate(., var1 = rownames(.))

  coef_var <- coef %>%
    dplyr::filter(str_detect(var1, "Intercept") | str_detect(var1, var_model))

  mm <- model.matrix(modelo)
  mm_t <- mm %>% as.data.frame() %>%
    select(contains("intercept"), contains(var_model)) %>%
    mutate(fecha = row_number()) %>%
    gather(., key = var, value = value, -fecha)

  calc <- mm_t %>%
    left_join(x = ., y = coef_var, by = c("var" = "var1") ) %>%
    mutate(pred = value * coef) %>%
    select(fecha, var, pred) %>%
    spread(., key = var, value = pred) %>%
    mutate(suma = rowSums(x = .[2:11]))

  tabla_orig <- modelo$model %>% as.data.frame()

  suma_vs_var <- cbind.data.frame(calc$suma, tabla_orig[,var_model])
  names(suma_vs_var) <- c("suma",var_model)
  suma_vs_var <- suma_vs_var %>%
    arrange_(var_model)

  df_plot <- tibble(
    y = modelo$y,
    var_x = tabla_orig[,var_model],
    pred_var = suma_vs_var$suma,
    var_x_arranged = suma_vs_var[, var_model]
  )

  ggplot(data = df_plot) +
    geom_point( aes( x = var_x, y = y)) +
    geom_line( aes( x = var_x_arranged, y = pred_var), col = "red", lwd = 2) +
    xlab(label = var_model) +
    ylab(label = names(fitchart$model)[1])
  #plot(modelo$y ~ tabla_orig[,var_model])
  #lines(suma_vs_var$suma ~ suma_vs_var[, var_model], col = "red", lwd = 2)

}
